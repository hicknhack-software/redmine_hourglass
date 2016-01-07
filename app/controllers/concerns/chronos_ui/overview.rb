module ChronosUi
  module Overview
    extend ActiveSupport::Concern

    included do
      menu_item :chronos_overview, only: :index
    end

    def index
      @time_tracker = User.current.chronos_time_tracker || Chronos::TimeTracker.new

      @time_log_list_arguments = index_page_list_arguments :time_logs do |time_log_query|
        time_log_query.add_filter 'booked', '!', [true]
        time_log_query.column_names = time_log_query.default_columns_names - [:booked?]
      end
      @time_booking_list_arguments = index_page_list_arguments :time_bookings
    end

    private
    def index_page_list_arguments(query_identifier)
      query = query_class_map[query_identifier].new name: '_'
      query.group_by = :start
      query.add_filter 'date', 'w+lw', [true]
      query.add_filter 'user_id', '=', [User.current.id.to_s]
      yield query if block_given?
      params[:sort] = params["#{query_identifier}_sort"]
      @sort_default = [%w(date desc)]
      sort_update query.sortable_columns, "#{sort_name}_#{query_identifier}"
      query.sort_criteria = @sort_criteria.to_a
      list_arguments(query, per_page: 15, page_param: "#{query_identifier}_page").merge action_name: query_identifier.to_s, hide_per_page_links: true, sort_param_name: "#{query_identifier}_sort"
    end
  end
end
