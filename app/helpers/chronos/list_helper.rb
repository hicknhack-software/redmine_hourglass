module Chronos
  module ListHelper
    def column_header(column, sort_param_name)
      if column.sortable && sort_param_name.present?
        params[:sort] = params.delete sort_param_name
        result = super column
        result.gsub! /(?<!_)sort(?==)/, sort_param_name
        params[sort_param_name] = params.delete :sort
        result.html_safe
      else
        super column
      end
    end

    def grouped_entry_list(entries, query, count_by_group)
      previous_group, first = false, true
      entries.each do |entry|
        group_name = group_count = nil
        if query.grouped?
          column = query.group_by_column
          group = column.value entry
          group = group.to_date if column.groupable.include? 'DATE'
          totals_by_group = query.totalable_columns.inject({}) do |totals, column|
            totals[column] = query.total_by_group_for(column)
            totals
          end
          if group != previous_group || first
            if group.blank? && group != false
              group_name = "(#{l(:label_blank_value)})"
            else
              group_name = column_content(query.group_by_column, entry)
              group_name = format_object(group) if column.groupable.include? 'DATE'
            end
            group_name ||= ''
            group_count = count_by_group[group] ||
                count_by_group[group.to_s] ||
                (group.respond_to?(:id) && count_by_group[group.id])
            group_totals = totals_by_group.map { |column, t| total_tag(column, t[group] || t[group.to_s] || (group.respond_to?(:id) && t[group.id])) }.join(' ').html_safe
          end
        end
        yield entry, group_name, group_count, group_totals
        previous_group, first = group, false
      end
    end

    def date_content(entry)
      format_date entry.start
    end

    def start_content(entry)
      format_time entry.start, false
    end

    def stop_content(entry)
      format_time entry.stop, false
    end

    def chart_data
      data = Array.new
      ticks = Array.new
      tooltips = Array.new

      if @chart_query.valid?
        hours_per_date = @chart_query.hours_by_group
        dates = hours_per_date && hours_per_date.keys.sort
        if dates.present?
          date_range = (dates.first..dates.last)
          gap = (date_range.count / 8).ceil
          date_range.each do |date_string|
            hours = hours_per_date[date_string]
            data.push hours
            tooltips.push "#{date_string}, #{localized_hours_in_units hours}"
            # to get readable labels, we have to blank out some of them if there are to many
            # only set 8 labels and set the other blank
            ticks.push gap == 0 || (data.length - 1) % gap == 0 ? date_string : ''
          end
        end
      end
      [data, ticks, tooltips]
    end
  end
end
