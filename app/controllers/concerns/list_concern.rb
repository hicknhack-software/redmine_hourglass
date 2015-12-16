module ListConcern
  include Redmine::Pagination
  extend ActiveSupport::Concern

  def init_sort
    sort_init @query.sort_criteria.empty? ? [%w(id desc)] : @query.sort_criteria
    sort_update @query.sortable_columns
    @query.sort_criteria = sort_criteria.to_a
  end

  def set_list_arguments
    @list_arguments = {query: @query}
    if @query.valid?
      scope = @query.results_scope order: sort_clause
      count = scope.count
      count_by_group = @query.count_by_group
      paginator = Paginator.new count, per_page_option, params[:page]
      entries = scope.offset(paginator.offset).limit(paginator.per_page)
      @list_arguments.merge! count: count, count_by_group: count_by_group, paginator: paginator, entries: entries
    end
  end
end
