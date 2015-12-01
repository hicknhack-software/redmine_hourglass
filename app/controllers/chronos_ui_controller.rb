class ChronosUiController < ApplicationController
  include SortHelper
  include QueryConcern
  include ListConcern

  helper QueriesHelper
  helper IssuesHelper
  helper SortHelper
  helper Chronos::ApplicationHelper

  before_action :retrieve_query, :init_sort, :create_view_arguments, only: [:time_logs, :time_bookings]
  before_action :get_time_log, only: [:edit_time_logs, :book_time_logs]
  before_action :get_time_booking, only: [:edit_time_bookings]

  def index
    @time_tracker = User.current.chronos_time_tracker || Chronos::TimeTracker.new
  end

  def time_logs
  end

  def edit_time_logs
    render 'chronos_ui/time_logs/edit', layout: false
  end

  def book_time_logs
    @time_booking = @time_log.new_time_booking
    render 'chronos_ui/time_logs/book', layout: false
  end

  def time_bookings
  end

  def edit_time_bookings
    render 'chronos_ui/time_bookings/edit', layout: false
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
end
