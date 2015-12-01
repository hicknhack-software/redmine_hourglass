class ChronosUiController < ApplicationController
  include SortHelper
  include QueryConcern

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
  end

  def book_time_logs
  end

  def time_bookings
  end

  def edit_time_bookings
  end

  private
  def init_sort
    sort_init @query.sort_criteria.empty? ? [%w(id desc)] : @query.sort_criteria
    sort_update @query.sortable_columns
  end

  def create_view_arguments
    if @query.valid?
      scope = @query.results_scope order: sort_clause
      @count = scope.count
      @pages = Paginator.new @count, per_page_option, params[:page]
      @entries = scope.offset(@pages.offset).limit(@pages.per_page)
      @count_by_group = @query.count_by_group
    end
  end
end
