module Chronos
  class TimeTrackerQuery < Query
    include QueryBase

    set_available_columns(
        comments: {},
        user: {sortable: lambda { User.fields_for_order_statement }},
        date: {sortable: "#{queried_class.table_name}.start", groupable: "DATE(#{queried_class.table_name}.start)"},
        start: {},
        #hours: {totalable: true},
        project: {sortable: "#{Project.table_name}.name", groupable: "#{Project.table_name}.id"},
        activity: {sortable: "#{TimeEntryActivity.table_name}.position", groupable: "#{TimeEntryActivity.table_name}.id"},
        issue: {sortable: "#{Issue.table_name}.subject", groupable: "#{Issue.table_name}.id"}
    )

    def initialize_available_filters
      add_user_filter
      add_date_filter
      add_issue_filter
      if project
        add_sub_project_filter unless project.leaf?
      else
        add_project_filter if all_projects.any?
      end
      add_activity_filter
      add_available_filter 'comments', type: :text
    end

    def default_columns_names
      @default_columns_names ||= [:user, :date, :start, :hours, :project, :issue, :activity, :comments]
    end

    def base_scope
      super.includes(:user, :project, :activity, :issue)
    end
  end
end
