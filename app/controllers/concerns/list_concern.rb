module ListConcern
  include Redmine::Pagination
  extend ActiveSupport::Concern

  private
  def init_sort(query = @query)
    sort_init query.sort_criteria.empty? ? [%w(date asc)] : query.sort_criteria
    sort_update query.sortable_columns
    query.sort_criteria = @sort_criteria.to_a
  end

  def list_arguments(query = @query, options = {})
    list_arguments = {query: query, action_name: action_name, sort_criteria: @sort_criteria}
    if query.valid?
      scope = query.results_scope order: sort_clause
      count = scope.count
      paginator = Paginator.new count, options[:per_page] || per_page_option, params[options[:page_param] || :page], options[:page_param]
      entries = scope.offset(paginator.offset).limit(paginator.per_page)
      list_arguments.merge! count: count, paginator: paginator, entries: entries
    end
    list_arguments
  end

  def list_records(klass)
    authorize klass, :view?
    retrieve_query
    init_sort
    @list_arguments = list_arguments
  end

  def record_form(klass, action: :change?, template: :edit)
    record = authorize find_record(klass), action
    render_forms get_type(klass), [record], template
  end

  def bulk_record_form(klass, action: :change?, template: :edit)
    records = params[:ids].map do |id|
      record = klass.find_by(id: id) and policy(record).send(action) or next
    end.compact
    render_404 if records.empty?
    render_forms get_type(klass), records, template
  end

  def find_record(klass)
    klass.find_by(id: params[:id]) or render_404
  end

  def render_forms(type, records, template)
    render "hourglass_ui/#{type}/#{template}", locals: {"#{type}" => records}, layout: false unless performed?
  end

  def get_type(klass)
    klass.name.demodulize.tableize
  end
end
