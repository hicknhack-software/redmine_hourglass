class ChronosUiController < ApplicationController
  include SortHelper
  include QueryConcern

  helper QueriesHelper
  helper IssuesHelper
  helper SortHelper
  helper Chronos::ApplicationHelper

  before_action :retrieve_query, only: [:time_logs]

  def index
    @time_tracker = User.current.chronos_time_tracker || Chronos::TimeTracker.new
  end

  def time_logs
    sort_init @query.sort_criteria.empty? ? [%w(id desc)] : @query.sort_criteria
    sort_update @query.sortable_columns

    if @query.valid?
      scope = @query.results_scope order: sort_clause
      @count = scope.count
      @pages = Paginator.new @count, per_page_option, params[:page]
      @time_logs = scope.offset(@pages.offset).limit(@pages.per_page)
      @time_log_count_by_group = @query.count_by_group
    end
  end

  def time_bookings
  end
end
