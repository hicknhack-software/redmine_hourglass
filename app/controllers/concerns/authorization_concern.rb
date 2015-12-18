module AuthorizationConcern
  extend ActiveSupport::Concern

  private
  def find_optional_project
    @project = @request_resource.project
  end

  def authorize_with_project_or_global
    @project.present? ? authorize : authorize_global
  end

  def authorize_global(*args)
    super *args
    @authorize_global = true
  end

  def authorize_foreign
    unless @request_resource.user == User.current || allowed_to?("#{params[:action]}_foreign")
      respond_with_error :forbidden, t("chronos.api.#{controller_name}.errors.change_others_forbidden")
    end
  end

  def authorize_update_time
    controller_params = params[controller_name.singularize]
    has_start_or_stop_parameter = controller_params && (controller_params.include?(:start) || controller_params.include?(:stop))
    if has_start_or_stop_parameter && !allowed_to?('update_time')
      respond_with_error :forbidden, t("chronos.api.#{controller_name}.errors.update_time_forbidden")
    end
  end

  def allowed_to?(action, controller = params[:controller])
    User.current.allowed_to?({controller: controller, action: action}, @project, {global: @authorize_global})
  end
end
