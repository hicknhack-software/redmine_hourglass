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
    @time_booking = @time_log.build_time_booking
    render 'chronos_ui/time_logs/book', layout: false
  end

  def time_bookings
    fetch_chart_data
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

  def fetch_chart_data
    @chart_data = Array.new
    @chart_ticks = Array.new
    @highlight_data = Array.new

    if @query.valid? && !(@entries.empty? || @entries.nil?)
      # if the user changes the date-order for the table values, we have to reorder it for the chart
      start_date = [@entries.last.start.to_date, @entries.first.start.to_date].min
      stop_date = [@entries.last.start.to_date, @entries.first.start.to_date].max

      (start_date..stop_date).map do |date|
        hours = 0
        @entries.each do |tb|
          hours += tb.hours if tb.start.to_date == date
        end
        @chart_data.push(hours)
        time_array = Chronos::DateTimeCalculations.format_hours hours
        @highlight_data.push [date, "#{time_array[0]}#{t('chronos.ui.chart.hour_sign')} #{time_array[1]}#{t('chronos.ui.chart.minute_sign')}"]

        # to get readable labels, we have to blank out some of them if there are to many
        # only set 8 labels and set the other blank
        gap = ((stop_date - start_date)/8).ceil
        if gap == 0 || (date - start_date) % gap == 0
          @chart_ticks.push(date)
        else
          @chart_ticks.push('')
        end
      end
    end
  end
end
