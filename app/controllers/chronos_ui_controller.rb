class ChronosUiController < ApplicationController
  include SortHelper
  include QueryConcern
  include ListConcern

  helper QueriesHelper
  helper IssuesHelper
  helper SortHelper
  helper Chronos::ApplicationHelper

  before_action :retrieve_query, :init_sort, :create_view_arguments, only: [:time_logs, :time_bookings]

  def index
    @time_tracker = User.current.chronos_time_tracker || Chronos::TimeTracker.new
  end

  def time_logs
  end

  def edit_time_logs
    render 'chronos_ui/time_logs/edit'
  end

  def book_time_logs
    render 'chronos_ui/time_logs/book'
  end

  def time_bookings
  end

  def edit_time_bookings
    render 'chronos_ui/time_bookings/edit'
  end
end
