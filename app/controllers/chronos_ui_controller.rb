class ChronosUiController < ApplicationController
  include SortHelper
  include QueryConcern
  include ListConcern

  helper QueriesHelper
  helper IssuesHelper
  helper SortHelper
  helper Chronos::ApplicationHelper
  helper Chronos::ListHelper
  helper Chronos::ReportHelper

  def index
    @time_tracker = User.current.chronos_time_tracker || Chronos::TimeTracker.new

    @time_log_list_arguments = index_page_list_arguments :time_logs do |time_log_query|
      time_log_query.add_filter 'booked', '!', [true]
    end
    @time_booking_list_arguments = index_page_list_arguments :time_bookings
  end

  def time_logs
    retrieve_query
    init_sort
    @list_arguments = list_arguments
  end

  def edit_time_logs
    render 'chronos_ui/time_logs/edit', locals: {time_log: get_time_log}, layout: false
  end

  def book_time_logs
    time_log = get_time_log
    render 'chronos_ui/time_logs/book', locals: {time_log: time_log, time_booking: time_log.build_time_booking}, layout: false
  end

  def time_bookings
    retrieve_query
    init_sort
    @list_arguments = list_arguments
    build_chart_query
  end

  def edit_time_bookings
    render 'chronos_ui/time_bookings/edit', locals: {time_booking: get_time_booking}, layout: false
  end

  def report
    @query_identifier = :time_bookings
    retrieve_query
    init_sort
    @list_arguments = list_arguments
    @list_arguments[:entries] = @list_arguments[:entries].offset(nil).limit(nil)
    build_chart_query
    render layout: false
  end

  private
  def get_time_log
    time_log = Chronos::TimeLog.find_by id: params[:id]
    render_404 unless time_log.present?
    time_log
  end

  def get_time_booking
    time_booking = Chronos::TimeBooking.find_by id: params[:id]
    render_404 unless time_booking.present?
    time_booking
  end

  def index_page_list_arguments(query_identifier)
    query = query_class_map[query_identifier].new name: '_'
    query.group_by = :start
    query.add_filter 'start_date', 'w+lw', [true]
    query.add_filter 'user_id', '=', [User.current.id.to_s]
    yield query if block_given?
    init_sort query
    list_arguments(query, per_page: 15, page_param: "#{query_identifier}_page").merge action_name: query_identifier.to_s, hide_per_page_links: true
  end
end
