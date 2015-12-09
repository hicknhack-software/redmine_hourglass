module Chronos::QueryBase
  extend ActiveSupport::Concern

  included do
    def initialize(attributes = nil, *args)
      super attributes
      self.filters ||= {}
    end

    def is_private?
      visibility == VISIBILITY_PRIVATE
    end

    def is_public?
      !is_private?
    end

    def results_scope(options = {})
      order_option = [group_by_sort_order, options[:order]].flatten.reject(&:blank?)
      base_scope.
          order(order_option).
          joins(joins_for_order_statement(order_option.join(',')))
    end

    def count_by_group
      grouped_query do |scope|
        scope.count
      end
    end
  end
end