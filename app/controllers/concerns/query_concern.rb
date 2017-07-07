module QueryConcern
  extend ActiveSupport::Concern

  included do
    helper_method :query_class, :query_identifier
  end

  private
  def query_class_map
    {
        time_logs: Hourglass::TimeLogQuery,
        time_bookings: Hourglass::TimeBookingQuery,
        time_trackers: Hourglass::TimeTrackerQuery
    }.with_indifferent_access
  end

  def query_class
    @query_identifier ||= params[:query_class] || action_name
    @query_class ||= query_class_map[@query_identifier]
  end

  def query_identifier
    @query_identifier
  end

  def retrieve_query(force_new: false)
    @query = if force_new || params[:set_filter] == '1' || session[session_query_var_name].nil?
               new_query
             elsif params[:query_id].present?
               query_from_id
             elsif session[session_query_var_name]
               query_from_session
             end
    @query.project = @project
    @query.add_filter 'user_id', '=', ['me'] unless policy(@query_class.queried_class).allowed_to?(:view_foreign)
  end

  def session_query_var_name
    query_class.name.underscore.to_sym
  end

  def query_from_id
    query = Query.where(project: [nil, @project]).find(params[:query_id])
    #raise ::Unauthorized unless query.visible?
    session[session_query_var_name] = {id: query.id}
    sort_clear
    query
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def new_query
    query = query_class.build_from_params params, name: '_'
    session[session_query_var_name] = {
        filters: query.filters,
        group_by: query.group_by,
        column_names: query.column_names,
        options: {
            totalable_names: query.totalable_names
        }
    }
    query
  end

  def query_from_session
    query_class.find_by(id: session[session_query_var_name][:id]) || query_class.new(session[session_query_var_name].merge name: '_')
  end

  def build_chart_query
    @chart_query = Hourglass::ChartQuery.new name: '_', filters: @query.filters, group_by: :date, main_query: @query
  end
end
