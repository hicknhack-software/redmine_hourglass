module AuthorizationConcern
  extend ActiveSupport::Concern

  private
  def find_project
    @project = @request_resource.project
  end

  def find_project_from_params
    controller_params = params[controller_name.singularize]
    if controller_params[:issue_id].present?
      issue = Issue.visible.find_by id: controller_params[:issue_id]
      render_404 message: t('chronos.api.errors.booking_issue_not_found') unless issue.present?
      @project = issue.project
    else
      @project = Project.visible.find_by id: controller_params[:project_id]
    end
    render_404 message: t('chronos.api.errors.booking_project_not_found') unless @project.present?
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
