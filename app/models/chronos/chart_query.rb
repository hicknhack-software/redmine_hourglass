module Chronos
  class ChartQuery < TimeBookingQuery

    attr_accessor :main_query
    
    def initialize(attributes = nil)
      self.main_query = attributes.delete :main_query
      super
    end

    def total_for_hours(scope)
      scope = scope.group(main_query.group_by_statement) if main_query.group_by_statement
      scope.group("#{TimeEntry.table_name}.project_id").sum("#{TimeEntry.table_name}.hours").each_with_object({}) do |((date, column, project_id), total), totals|
        totals[date] ||= {}
        totals[date][column] ||= {}
        if project_id
          totals[date][column][project_id] = total
        else
          totals[date][column] = total
        end
      end
    end
  end
end
