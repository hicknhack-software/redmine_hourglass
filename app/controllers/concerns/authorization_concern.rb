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
      yield if block_given?
    end
  end

  def allowed_to?(action, controller = params[:controller])
    User.current.allowed_to?({controller: controller, action: action}, @project, {global: @authorize_global})
  end
end
