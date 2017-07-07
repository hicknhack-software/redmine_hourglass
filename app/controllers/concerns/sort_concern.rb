module SortConcern
  include SortHelper
  extend ActiveSupport::Concern
  
  private
  def init_sort(query = @query)
    sort_init query.sort_criteria.empty? ? [%w(date asc)] : query.sort_criteria
    sort_update query.sortable_columns
    query.sort_criteria = @sort_criteria.to_a
  end
end
