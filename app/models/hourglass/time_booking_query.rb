module Hourglass
  class TimeBookingQuery < Query
    include QueryBase

    set_available_columns(
        date: {sortable: "#{queried_class.table_name}.start", groupable: "DATE(#{queried_class.table_name}.start)"},
        start: {},
        stop: {},
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
      add_date_filter
      add_issue_filter
      if project
        add_sub_project_filter unless project.leaf?
      else
        add_project_filter if all_projects.any?
      end
      add_activity_filter
      add_fixed_version_filter
      add_comments_filter
      add_associations_custom_fields_filters :user, :project, :activity, :fixed_version
      add_custom_fields_filters issue_custom_fields, :issue
      add_custom_fields_filters TimeEntryCustomField, :time_entry
      # we need fix the last added filters cause redmine fucks up the name
      available_filters.select { |k, _| k.start_with? 'time_entry' }.each do |_, v|
        v[:name] = v[:field].name
      end
    end

    def available_columns
      @available_columns ||= self.class.available_columns.dup.tap do |available_columns|
        {
            time_entry: TimeEntryCustomField,
            issue: issue_custom_fields,
            project: ProjectCustomField,
            user: UserCustomField,
            fixed_version: VersionCustomField

        }.each do |association, custom_field_scope|
          custom_field_scope.visible.each do |custom_field|
            available_columns << QueryAssociationCustomFieldColumn.new(association, custom_field)
          end
        end
      end
    end

    def default_columns_names
      @default_columns_names ||= [:date, :start, :stop, :hours, :project, :issue, :activity, :comments]
    end

    def base_scope
      super.visible.eager_load(:time_entry, :activity, :user, :project, issue: :fixed_version)
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

    def sql_for_comments_field(field, operator, value)
      sql_for_field(field, operator, value, TimeEntry.table_name, 'comments')
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
      scope.group("#{TimeEntry.table_name}.project_id").sum("#{TimeEntry.table_name}.hours").each_with_object({}) do |((column, project_id), total), totals|
        totals[column] ||= {}
        if project_id
          totals[column][project_id] = total
        else
          totals[column] = total
        end
      end
    end

    def has_through_associations
      %i(user issue project activity fixed_version)
    end
  end
end
