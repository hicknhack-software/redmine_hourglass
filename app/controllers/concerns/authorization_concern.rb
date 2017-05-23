module AuthorizationConcern
  extend ActiveSupport::Concern

  private
  def find_project
    @project = @request_resource.project
  end

  def find_project_from_params(resource_params, mode: :render)
    if resource_params[:issue_id].present?
      issue = Issue.visible.find_by id: resource_params[:issue_id]
      unless issue.present?
        render_404 message: t('hourglass.api.errors.booking_issue_not_found') if mode == :render
        return t('hourglass.api.errors.booking_issue_not_found')
      end
      @project = issue.project
    else
      @project = Project.visible.find_by id: resource_params[:project_id]
    end
    unless @project.present?
      render_404 message: t('hourglass.api.errors.booking_project_not_found') if mode == :render
      t('hourglass.api.errors.booking_project_not_found')
    end
  end

  def authorize_global(*args)
    super
    @authorize_global = true
  end

  def authorize_foreign
    unless foreign_allowed_to?
      yield if block_given?
    end
  end

  def foreign_allowed_to?(resource = @request_resource)
    resource.user == User.current || allowed_to?("#{params[:action]}_foreign")
  end

  def allowed_to?(action = params[:action], controller = params[:controller])
    User.current.allowed_to?({controller: controller, action: action}, @project, {global: @authorize_global})
  end
end
