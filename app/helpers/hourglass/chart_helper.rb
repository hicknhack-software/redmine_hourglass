module Hourglass
  module ChartHelper

    # works only for time bookings for now
    def chart_data(chart_query)
      data = Hash.new([].freeze)
      ticks = []
      tooltips = Hash.new([].freeze)

      if chart_query.valid?
        hours_per_date_without_column = hours_per_date chart_query
        dates = hours_per_date_without_column.keys.compact.sort
        if dates.present?
          group_key_is_string = dates.first.is_a?(String)
          date_range = group_key_is_string ? (Date.parse(dates.first)..Date.parse(dates.last)) : (dates.first..dates.last)
          hours_per_column_per_date(hours_per_date_without_column).each do |column, hours_per_date|
            date_range.each do |date|
              hours = hours_per_date[group_key_is_string ? date.to_s : date]
              data[column] += [hours || 0.0]
              tooltips[column] += ["#{format_date date.to_time}, #{localized_hours_in_units hours}"]
            end
          end
          ticks = calculate_ticks date_range
        end
      end
      [data.values, ticks, tooltips.values]
    end

    private
    # to get readable labels, we have to blank out some of them if there are to many
    def calculate_ticks(date_range)
      gap = [(date_range.count / 8.to_f).ceil, 1].max
      date_range.each_with_index.map { |date, i| i % gap == 0 ? format_date(date.to_time) : '' }
    end

    def hours_per_date(query)
      total = query.total_by_group_for(:hours) 
      total = query.total_for(:hours) if total == nil
      total.transform_values do |totals_by_column|
        totals_by_column = {default: totals_by_column} unless query.main_query.grouped?
        totals_by_column.transform_keys! { |_| :default } if query.main_query.group_by == 'date'
        Hash[totals_by_column.map { |column, total| [column, unrounded_total(total)] }]
      end
    end

    def unrounded_total(total)
      total.reduce(0.0) do |sum, total_by_project|
        sum + total_by_project[1].to_f.round(2)
      end
    end

    def hours_per_column_per_date(hours_per_date)
      hours_per_date.each_with_object({}) do |(date, hours_per_column), hours_per_column_per_date|
        hours_per_column.each do |project_id, hours|
          hours_per_column_per_date[project_id] ||= {}
          hours_per_column_per_date[project_id][date] = hours
        end
      end
    end
  end
end
