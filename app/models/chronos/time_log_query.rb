module Chronos
  class TimeLogQuery < Query
    include QueryBase
    self.queried_class = TimeLog

    self.available_columns = [
        QueryColumn.new(:comments),
        QueryColumn.new(:user, sortable: lambda { User.fields_for_order_statement }, groupable: "#{User.table_name}.id"),
        QueryColumn.new(:start, sortable: "#{TimeLog.table_name}.start", default_order: 'desc', groupable: "#{TimeLog.table_name}.start"),
        QueryColumn.new(:stop, sortable: "#{TimeLog.table_name}.stop", default_order: 'desc', groupable: "#{TimeLog.table_name}.stop")
    ]

    def initialize_available_filters
      add_available_filter 'comments', type: :text
      add_users_filter
      add_sub_projects_filter if project && !project.leaf?
    end

    def default_columns_names
      @default_columns_names ||= [:start, :stop, :user, :comments]
    end

    def base_scope
      TimeLog.
          includes(:user, :time_booking).
          where(statement)
    end
  end
end
