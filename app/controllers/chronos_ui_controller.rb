class ChronosUiController < ApplicationController
  include SortHelper

  helper QueriesHelper
  helper IssuesHelper
  helper SortHelper
  helper Chronos::ApplicationHelper

  helper_method :query_class

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

  private
  def query_class
    @query_class ||= {
        time_logs: Chronos::TimeLogQuery
    }.with_indifferent_access[action_name]
  end

  def retrieve_query
    @query = if params[:query_id].present?
               query_from_id
             elsif params[:set_filter] == '1' || session[session_query_var_name].nil?
               new_query
             elsif session[session_query_var_name]
               query_from_session
             end
  end

  def session_query_var_name
    query_class.name.underscore.to_sym
  end

  def query_from_id
    query = Query.find(params[:query_id])
    #raise ::Unauthorized unless query.visible?
    session[session_query_var_name] = {id: query.id}
    sort_clear
    query
  end

  def new_query
    query = query_class.build_from_params params, name: '_'
    session[session_query_var_name] = {
        filters: query.filters,
        group_by: query.group_by,
        column_names: query.column_names
    }
    query
  end

  def query_from_session
    query_class.find_by(id: session[session_query_var_name][:id]) || query_class.new(session[session_query_var_name].merge name: '_')
  end
end
