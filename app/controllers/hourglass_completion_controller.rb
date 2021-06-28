class HourglassCompletionController < Hourglass::ApiBaseController
  include Hourglass::ApplicationHelper

  accept_api_auth :issues, :activities

  def issues
    issue_arel = Issue.arel_table
    id_as_text = case Issue.connection.adapter_name
                 when 'PostgreSQL', 'SQLite'
                   Arel::Nodes::NamedFunction.new("CAST", [ issue_arel[:id].as("VARCHAR") ])
                 when 'Mysql2', 'MySQL'
                   Arel::Nodes::NamedFunction.new("CAST", [ issue_arel[:id].as("CHAR(50)") ])
                 else
                   issue_arel[:id] # unknown
                 end
    was_admin = User.current.admin?
    User.current.admin = false # prevent Redmine from ignoring permissions for admins, like we do later anyways
    project = params[:project_id].present? ? Project.find(params[:project_id]) : nil
    issues = Issue.cross_project_scope(project).visible
    issues = issues.joins(:project).where(Project.allowed_to_one_of_condition User.current, Hourglass::AccessControl.permissions_from_action(controller: 'hourglass/time_logs', action: 'book')).where(
        issue_arel[:id].eq(params[:term].to_i)
            .or(id_as_text.matches("%#{params[:term]}%"))
            .or(issue_arel[:subject].matches("%#{params[:term]}%"))
    )
    issue_list = issues.map do |issue|
      {
          label: "##{issue.id} #{issue.subject}",
          issue_id: "#{issue.id}",
          project_id: issue.project.id}
    end
    User.current.admin = was_admin
    respond_with_success issue_list
  end

  def activities
    activities = TimeEntryActivity.applicable(User.current.projects.find_by id: params[:project_id])
    default_activity = User.current.default_activity activities
    activities_result = activities.map do |activity|
      {id: activity.id, name: activity.name, isDefault: default_activity && activity.name == default_activity.name}
    end
    respond_with_success activities_result
  end

  def users
    project = User.current.projects.find_by id: params[:project_id]
    users = project.nil? || User.current.allowed_to?(:hourglass_edit_booked_time, project) ? user_collection(project) : [User.current]
    respond_with_success users.map { |user| {id: user.id, name: user.name} }
  end
end
