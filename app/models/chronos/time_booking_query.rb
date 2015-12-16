module Chronos
  class TimeBookingQuery < Query
    include QueryBase

    set_available_columns(
      start: {sortable: "#{queried_class.table_name}.start", groupable: "DATE(#{queried_class.table_name}.start)"},
      stop: {sortable: "#{queried_class.table_name}.stop", groupable: "DATE(#{queried_class.table_name}.stop)"},
      hours: {totalable: true},
      comments: {},
      user: {sortable: lambda { User.fields_for_order_statement }, groupable: "#{User.table_name}.id"},
      project: {sortable: "#{Project.table_name}.name", groupable: "#{Project.table_name}.id"},
      activity: {sortable: "#{TimeEntryActivity.table_name}.position", groupable: "#{TimeEntryActivity.table_name}.id"},
      issue: {sortable: "#{Issue.table_name}.subject", groupable: "#{Issue.table_name}.id"},
      fixed_version: {sortable: lambda { Version.fields_for_order_statement }, groupable: "#{Issue.table_name}.fixed_version_id"}
    )

    def initialize_available_filters
      add_user_filter
      add_start_filter
      add_issue_filter
      if project
        add_sub_project_filter unless project.leaf?
      else
        add_project_filter if all_projects.any?
      end
      add_activity_filter
      add_fixed_version_filter
      add_available_filter 'comments', type: :text
    end

    def default_columns_names
      @default_columns_names ||= [:start, :stop, :hours, :project, :issue, :activity, :comments]
    end

    def base_scope
      super.joins(:user, :project, :activity).eager_load(issue: :fixed_version)
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

    def total_for_hours(scope)
      map_total(scope.sum("#{TimeEntry.table_name}.hours")) { |t| t.to_f.round(2) }
    end
  end
end
