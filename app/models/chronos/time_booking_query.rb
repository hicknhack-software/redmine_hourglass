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
        QueryColumn.new(:issue, sortable: "#{Issue.table_name}.subject", groupable: "#{Issue.table_name}.id")
    ]

    def initialize_available_filters
      add_available_filter 'comments', type: :text
      add_users_filter
      add_activities_filter
      if project
        add_sub_projects_filter unless project.leaf?
      else
        add_projects_filter if all_projects.any?
      end
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
      "( #{User.table_name}.id #{operator == '=' ? 'IN' : 'NOT IN'} (" + value.collect { |val| "'#{self.class.connection.quote_string(val)}'" }.join(',') + ') )'
    end
  end
end
