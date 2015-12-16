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

  before_action :get_time_log, only: [:edit_time_logs, :book_time_logs]
  before_action :get_time_booking, only: [:edit_time_bookings]

  def index
    @time_tracker = User.current.chronos_time_tracker || Chronos::TimeTracker.new
  end

  def time_logs
    retrieve_query
    init_sort
    set_list_arguments
  end

  def edit_time_logs
    render 'chronos_ui/time_logs/edit', layout: false
  end

  def book_time_logs
    @time_booking = @time_log.build_time_booking
    render 'chronos_ui/time_logs/book', layout: false
  end

  def time_bookings
    retrieve_query
    init_sort
    set_list_arguments
    build_chart_query
  end

  def edit_time_bookings
    render 'chronos_ui/time_bookings/edit', layout: false
  end

  def report
    use_booking_query
    retrieve_query
    init_sort
    set_list_arguments
    @list_arguments[:entries] = @list_arguments[:entries].offset(nil).limit(nil)
    build_chart_query
    render layout: false
  end

  private
  def get_time_log
    @time_log = Chronos::TimeLog.find_by id: params[:id]
    render_404 unless @time_log.present?
  end

  def get_time_booking
    @time_booking = Chronos::TimeBooking.find_by id: params[:id]
    render_404 unless @time_booking.present?
  end

  def use_booking_query
    @query_identifier = :time_bookings
  end
end
