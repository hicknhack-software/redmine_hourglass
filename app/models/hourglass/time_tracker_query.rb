module Hourglass
  class TimeTrackerQuery < Query
    include QueryBase
    self.queried_class = TimeTracker

    self.available_columns = [
      QueryColumn.new(:comments),
      QueryColumn.new(:user, sortable: lambda { User.fields_for_order_statement }, groupable: true),
      TimestampQueryColumn.new(:date, sortable: "#{TimeTracker.table_name}.start", groupable: true),
      QueryColumn.new(:start),
      QueryColumn.new(:hours),
      QueryColumn.new(:project, sortable: "#{Project.table_name}.name", groupable: true),
      QueryColumn.new(:activity, sortable: "#{TimeEntryActivity.table_name}.position", groupable: true),
      QueryColumn.new(:issue, sortable: "#{Issue.table_name}.subject", groupable: true),
      QueryColumn.new(:fixed_version, sortable: lambda { Version.fields_for_order_statement }, groupable: true),
    ]

    def initialize(attributes=nil, *args)
      super attributes
      self.filters ||= {}
    end

    def initialize_available_filters
      add_user_filter
      add_date_filter
      add_issue_filter
      if project
        add_sub_project_filter unless project.leaf?
      elsif all_projects.any?
        add_project_filter
      end
      add_activity_filter
      add_fixed_version_filter
      add_comments_filter
      add_associations_custom_fields_filters :user, :project, :activity, :fixed_version
      add_custom_fields_filters issue_custom_fields, :issue
    end

    def available_columns
      @available_columns ||= self.class.available_columns.dup.tap do |available_columns|
        available_columns.push *associated_custom_field_columns(:issue, issue_custom_fields, totalable: false)
        available_columns.push *associated_custom_field_columns(:project, project_custom_fields, totalable: false)
        # 2021-07-06 arBmind: custom fields for users cannot be properly authorized
        # available_columns.push *associated_custom_field_columns(:user, UserCustomField, totalable: false)
        available_columns.push *associated_custom_field_columns(:fixed_version, VersionCustomField, totalable: false)
      end
    end

    def default_columns_names
      @default_columns_names ||= [:user, :date, :start, :hours, :project, :issue, :activity, :comments]
    end

    def base_scope
      super.eager_load(:user, :project, :activity, issue: :fixed_version)
    end

    def sql_for_fixed_version_id_field(field, operator, value)
      sql_for_field(field, operator, value, Issue.table_name, 'fixed_version_id')
    end

    def sql_for_custom_field(*args)
      result = super
      result.gsub! /#{queried_table_name}\.(fixed_version)_id/ do
        groupable_columns.select { |c| c.name === $1.to_sym }.first.groupable
      end
      result
    end

    def sql_for_comments_field(field, operator, value)
      sql_for_field(field, operator, value, TimeTracker.table_name, 'comments', true)
    end

    def has_through_associations
      %i(fixed_version)
    end
  end
end
