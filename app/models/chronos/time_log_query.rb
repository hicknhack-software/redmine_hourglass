module Chronos
  class TimeLogQuery < Query
    self.queried_class = TimeLog

    self.available_columns = [
        QueryColumn.new(:comments),
        QueryColumn.new(:user, sortable: lambda { User.fields_for_order_statement }, groupable: true),
        QueryColumn.new(:start, sortable: "#{TimeLog.table_name}.start", default_order: 'desc', groupable: true),
        QueryColumn.new(:stop, sortable: "#{TimeLog.table_name}.stop", default_order: 'desc', groupable: true)
    ]

    def initialize_available_filters
      #add_available_filter 'start', type: :date_past
      #add_available_filter 'stop', type: :date_past
      add_available_filter 'comments', type: :text
    end

    def results_scope(options = {})
      order_option = [group_by_sort_order, options[:order]].flatten.reject(&:blank?)

      TimeLog.
          where(statement).
          order(order_option).
          joins(joins_for_order_statement(order_option.join(',')))
    end
  end
end