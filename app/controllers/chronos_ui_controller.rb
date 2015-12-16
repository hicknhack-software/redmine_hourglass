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

    query_params = {group_by: :start, filter: {user: {operator: '=', values: [User.current.id]}, start: {operator: 'l2w'}}}

    query = Chronos::TimeLogQuery.build_from_params query_params, name: '_'
    init_sort query
    @time_log_list_arguments = list_arguments(query).merge action_name: 'time_logs'
    query = Chronos::TimeLogQuery.build_from_params query_params, name: '_'
    init_sort query
    @time_booking_list_arguments = list_arguments(query).merge action_name: 'time_bookings'
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
    time_booking = time_log.build_time_booking
    render 'chronos_ui/time_logs/book', locals: {time_log: time_log, time_booking: time_booking}, layout: false
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
end
