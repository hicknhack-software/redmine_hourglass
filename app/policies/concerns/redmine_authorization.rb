module RedmineAuthorization
  private
  def authorized?(action)
    return foreign_authorized? action if foreign_entry?
    allowed_to? action
  end

  def foreign_authorized?(action)
    foreign_forbidden_message and return false unless allowed_to? "#{action}_foreign"
    true
  end

  def foreign_entry?
    record_user && record_user != user
  end

  def unsafe_attributes?
    return false unless record.respond_to? :changed
    unsafe_attributes = record.changed.map(&:to_sym).select { |attr| protected_parameters.include? attr }
    if record.new_record?
      unsafe_attributes.delete :user_id
      unsafe_attributes.delete :start
    end
    unsafe_attributes.length > 0
  end

  def allowed_to?(action)
    action_args = {controller: "hourglass/#{controller_name}", action: action}
    project.blank? ? user.allowed_to_globally?(action_args) : user.allowed_to?(action_args, project)
  end

  def controller_name
    self.class.name.gsub('::Scope', '').demodulize.gsub('Policy', '').tableize
  end

  def foreign_forbidden_message
    @message ||= I18n.t('hourglass.api.errors.change_others_forbidden')
  end

  def update_all_forbidden_message
    @message ||= I18n.t('hourglass.api.errors.update_all_forbidden')
  end
end
