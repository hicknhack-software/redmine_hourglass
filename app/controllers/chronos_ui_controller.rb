class ChronosUiController < ApplicationController
  include SortHelper
  include QueryConcern
  include ListConcern
  include AuthorizationConcern

  helper QueriesHelper
  helper IssuesHelper
  helper SortHelper
  helper Chronos::ApplicationHelper
  helper Chronos::ListHelper
  helper Chronos::ReportHelper

  menu_item :chronos_overview, only: :index
  menu_item :chronos_time_logs, only: :time_logs
  menu_item :chronos_time_bookings, only: :time_bookings

  before_filter :authorize_global

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
    time_log = get_time_log
    authorize_foreign
    render 'chronos_ui/time_logs/edit', locals: {time_log: time_log}, layout: false unless performed?
  end

  def book_time_logs
    time_log = get_time_log
    authorize_foreign
    render 'chronos_ui/time_logs/book', locals: {time_log: time_log, time_booking: time_log.build_time_booking}, layout: false unless performed?
  end

  def time_bookings
    retrieve_query
    init_sort
    @list_arguments = list_arguments
    build_chart_query
  end

  def edit_time_bookings
    time_booking = get_time_booking
    authorize_foreign
    render 'chronos_ui/time_bookings/edit', locals: {time_booking: time_booking}, layout: false unless performed?
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
    @request_resource = time_log
  end

  def get_time_booking
    time_booking = Chronos::TimeBooking.find_by id: params[:id]
    render_404 unless time_booking.present?
    @request_resource = time_booking
  end

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

  def authorize_foreign
    super do
      render_403
    end
  end
end
