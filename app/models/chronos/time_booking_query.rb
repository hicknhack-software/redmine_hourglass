module Chronos
  class TimeBookingQuery < Query
    include QueryBase
    self.queried_class = TimeBooking

    self.available_columns = [
        QueryColumn.new(:start, sortable: "#{TimeBooking.table_name}.start", default_order: 'desc', groupable: "#{TimeBooking.table_name}.start"),
        QueryColumn.new(:stop, sortable: "#{TimeBooking.table_name}.stop", default_order: 'desc', groupable: "#{TimeBooking.table_name}.stop"),
        QueryColumn.new(:comments),
        QueryColumn.new(:user, sortable: lambda { User.fields_for_order_statement }, groupable: "#{User.table_name}.id"),
        QueryColumn.new(:project, sortable: "#{Project.table_name}.name", groupable: "#{Project.table_name}.id"),
        QueryColumn.new(:activity, sortable: "#{TimeEntryActivity.table_name}.position", groupable: "#{TimeEntryActivity.table_name}.id"),
        QueryColumn.new(:issue, sortable: "#{Issue.table_name}.subject", groupable: "#{Issue.table_name}.id"),
        QueryColumn.new(:fixed_version, sortable: lambda { Version.fields_for_order_statement }, groupable: "#{Version.table_name}.id")
    ]

    def initialize_available_filters
      add_users_filter
      add_issues_filter
      if project
        add_sub_projects_filter unless project.leaf?
      else
        add_projects_filter if all_projects.any?
      end
      add_activities_filter
      add_fixed_versions_filter
      add_available_filter 'comments', type: :text
    end

    def default_columns_names
      @default_columns_names ||= [:start, :stop, :user, :project, :issue, :activity, :comments]
    end

    def base_scope
      TimeBooking.
          joins(:user, :project, :activity).
          eager_load(:issue).
          where(statement)
    end

    def sql_for_user_id_field(field, operator, value)
      sql_for_field(field, operator, value, User.table_name, 'id')
    end

    def sql_for_project_id_field(field, operator, value)
      sql_for_field(field, operator, value, Project.table_name, 'id')
    end

    def sql_for_issue_id_field(field, operator, value)
      sql_for_field(field, operator, value, Issue.table_name, 'id')
    end

    def sql_for_issue_subject_field(field, operator, value)
      sql_for_field(field, operator, value, Issue.table_name, 'subject')
    end
    def sql_for_fixed_version_id_field(field, operator, value)
      sql_for_field(field, operator, value, Issue.table_name, 'fixed_version_id')
    end

    def sql_for_activity_id_field(field, operator, value)
      condition_on_id = sql_for_field(field, operator, value, Enumeration.table_name, 'id')
      condition_on_parent_id = sql_for_field(field, operator, value, Enumeration.table_name, 'parent_id')
      if operator == '='
        "(#{condition_on_id} OR #{condition_on_parent_id})"
      else
        "(#{condition_on_id} AND #{condition_on_parent_id})"
      end
    end
  end
end
