module Chronos
  class ChartQuery < TimeBookingQuery
    def initialize(attributes = nil)
      @original_query_group_by_statement = attributes.delete :original_query_group_by_statement
      super
    end

    def total_for_hours(scope)
      scope.group(@original_query_group_by_statement).group("#{TimeEntry.table_name}.project_id").sum("#{TimeEntry.table_name}.hours").each_with_object({}) do |((date, column, project_id), total), totals|
        totals[date] ||= {}
        totals[date][column] ||= {}
        totals[date][column][project_id] = total
      end
    end
  end
end
