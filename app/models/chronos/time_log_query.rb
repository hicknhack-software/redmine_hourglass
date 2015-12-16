module Chronos
  class TimeLogQuery < Query
    include QueryBase

    set_available_columns(
        comments: {},
        user: {sortable: lambda { User.fields_for_order_statement }, groupable: true},
        start: {sortable: "#{queried_class.table_name}.start", groupable: "DATE(#{queried_class.table_name}.start)"},
        stop: {sortable: "#{queried_class.table_name}.stop", groupable: "DATE(#{queried_class.table_name}.stop)"},
        hours: {totalable: true},
        booked?: {}
    )

    def initialize_available_filters
      add_user_filter
      add_start_filter
      add_available_filter 'comments', type: :text
    end

    def default_columns_names
      @default_columns_names ||= [:start, :stop, :hours, :comments, :booked?]
    end

    def base_scope
      super.includes(:user, :time_booking)
    end

    def total_for_hours(scope)
      map_total(
          scope.sum("(strftime('%s', #{queried_class.table_name}.stop) - strftime('%s', #{queried_class.table_name}.start))")
      ) { |t| Chronos::DateTimeCalculations.in_hours(t).round(2) }
    end
  end
end
