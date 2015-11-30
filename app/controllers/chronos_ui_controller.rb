class ChronosUiController < ApplicationController
  include SortHelper

  helper Chronos::ApplicationHelper
  helper QueriesHelper
  helper SortHelper

  def index
    @time_tracker = User.current.chronos_time_tracker || Chronos::TimeTracker.new
  end

  def time_logs
    @query = Chronos::TimeLogQuery.build_from_params params, name: '_'
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
