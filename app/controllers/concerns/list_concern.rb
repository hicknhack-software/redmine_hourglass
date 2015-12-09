module ListConcern
  include Redmine::Pagination
  extend ActiveSupport::Concern

  included do
    def init_sort
      sort_init @query.sort_criteria.empty? ? [%w(id desc)] : @query.sort_criteria
      sort_update @query.sortable_columns
      @query.sort_criteria = sort_criteria.to_a
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
end
