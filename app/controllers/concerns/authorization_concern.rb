module AuthorizationConcern
  extend ActiveSupport::Concern

  included do
    include Pundit

    def pundit_user
      User.current
    end

    def authorize(record, query = nil)
      super
      record
    end

    rescue_from(Pundit::NotAuthorizedError) do |e|
      render_403 message: e.policy.message
    end
  end

  private
  def find_project(resource = @request_resource)
    @project = resource.project
  end

  def find_project_from_params(resource_params, mode: :render)
    if resource_params[:issue_id].present?
      find_project_from_issue_id resource_params[:issue_id], mode
    elsif resource_params[:project_id].present?
      find_project_from_project_id resource_params[:project_id], mode
    end
  end

  def find_project_from_issue_id(id, mode)
    issue = Issue.visible.find_by id: id
    unless issue.present?
      render_404 message: t('hourglass.api.errors.booking_issue_not_found') if mode == :render
      return t('hourglass.api.errors.booking_issue_not_found')
    end
    @project = issue.project
  end

  def find_project_from_project_id(id, mode)
    project = Project.visible.find_by id: id
    unless project.present?
      render_404 message: t('hourglass.api.errors.booking_project_not_found') if mode == :render
      t('hourglass.api.errors.booking_project_not_found')
    end
    @project = project
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

  def foreign_allowed_to?(resource = @request_resource, action = params[:action], controller = params[:controller])
    resource.user == User.current || allowed_to?("#{action}_foreign", controller)
  end

  def allowed_to?(action = params[:action], controller = params[:controller])
    User.current.allowed_to?({controller: controller, action: action}, @project, {global: @authorize_global})
  end
end
