module Chronos
  class TimeLogQuery < Query
    include QueryBase
    self.queried_class = TimeLog

    self.available_columns = [
        QueryColumn.new(:comments),
        QueryColumn.new(:user, sortable: lambda { User.fields_for_order_statement }, groupable: true),
        QueryColumn.new(:start, sortable: "#{TimeLog.table_name}.start", default_order: 'desc', groupable: "DATE(#{TimeLog.table_name}.start)"),
        QueryColumn.new(:stop, sortable: "#{TimeLog.table_name}.stop", default_order: 'desc', groupable: "DATE(#{TimeLog.table_name}.stop)"),
        QueryColumn.new(:hours, totalable: true),
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

    def total_for_hours(scope)
      map_total(
          scope.sum("(strftime('%s', #{TimeLog.table_name}.stop) - strftime('%s', #{TimeLog.table_name}.start))")
      ) {|t| Chronos::DateTimeCalculations.in_hours(t).round(2)}
    end
  end
end
