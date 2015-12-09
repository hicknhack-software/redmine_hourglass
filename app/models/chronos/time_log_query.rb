module Chronos
  class TimeLogQuery < Query
    include QueryBase
    self.queried_class = TimeLog

    self.available_columns = [
        QueryColumn.new(:comments),
        QueryColumn.new(:user, sortable: lambda { User.fields_for_order_statement }, groupable: "#{User.table_name}.id"),
        QueryColumn.new(:start, sortable: "#{TimeLog.table_name}.start", default_order: 'desc', groupable: "DATE(#{TimeLog.table_name}.start)"),
        QueryColumn.new(:stop, sortable: "#{TimeLog.table_name}.stop", default_order: 'desc', groupable: "DATE(#{TimeLog.table_name}.stop)"),
        QueryColumn.new(:hours),
        QueryColumn.new(:booked?),
    ]

    def initialize_available_filters
      add_user_filter
      add_start_filter
      add_available_filter 'comments', type: :text
    end

    def default_columns_names
      @default_columns_names ||= [:start, :stop, :hours, :comments, :booked?]
    end

    def base_scope
      TimeLog.
          includes(:user, :time_booking).
          where(statement)
    end
  end
end
