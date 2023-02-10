module Hourglass
  module RedminePatches
    module QueryPatch
      extend ActiveSupport::Concern

      def self.prepended(klass)
        klass.class_eval do
          self.operators = operators.merge 'q' => :label_this_quarter, 'lq' => :label_last_quarter
          self.operators_by_filter_type[:date] += %w(q lq)
          self.operators_by_filter_type[:date_past] += %w(q lq)
        end
      end

      def validate_query_filters
        return unless filters
        temp = filters.dup
        self.filters = filters.delete_if { |field| operator_for(field) == 'q' || operator_for(field) == 'lq' }
        super
        self.filters = temp
      end
    end
  end
end
