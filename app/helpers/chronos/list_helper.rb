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
      return entry_list entries, &Proc.new unless query.grouped?

      grouped_entries(entries, query).each do |group, group_entries|
        yield nil, {
            name: group_name(group, query, group_entries.first),
            totals: group_totals(group, query, group_entries),
            count: group_count(group, count_by_group)
        }
        entry_list group_entries, &Proc.new
      end
    end

    def entry_list(entries)
      entries.each {|entry| yield entry}
    end

    def render_query_totals(query, entries = nil)
      return super(query) unless query.grouped? && entries
      return unless query.totalable_columns.present?
      content_tag 'p', class: 'query-totals' do
        totals_sum(query, entries).each do |column, total|
          concat total_tag(column, total)
        end
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
        hours_per_date = @chart_query.total_by_group_for :hours
        dates = hours_per_date && hours_per_date.keys.sort
        if dates.present?
          group_key_is_string = dates.first.is_a?(String)
          first_date = group_key_is_string ? Date.parse(dates.first) : dates.first
          last_date = group_key_is_string ? Date.parse(dates.last) : dates.last
          date_range = (first_date..last_date)
          gap = (date_range.count / 8).ceil
          date_range.each do |date|
            date_string = date.to_s
            hours = hours_per_date[group_key_is_string ? date_string : date]
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

    private
    def grouped_entries(entries, query)
      entries.group_by { |entry| query.column_value query.group_by_column, entry }
    end

    def group_count(group, counts)
      counts[group] || counts[group.to_s] || (group.respond_to?(:id) && counts[group.id])
    end

    def group_totals(group, query, entries)
      Hash[query.totalable_columns.map do |c|
        [c, query.total_by_group_for(c)]
      end.map do |column, t|
        total = t[group] || t[group.to_s] || (group.respond_to?(:id) && t[group.id])
        [
            column,
            query.queried_class == Chronos::TimeBooking ? round_time_booking_total(entries, total) : total
        ]
      end]
    end

    def totals_sum(query, entries)
      grouped_entries(entries, query).reduce(Hash.new(0)) do |totals, (group, group_entries)|
        group_totals(group, query, group_entries).each do |column, total|
          totals[column] += total
        end
        totals
      end
    end

    def group_name(group, query, first_entry)
      if group.blank? && group != false
        "(#{l(:label_blank_value)})"
      else
        column_content query.group_by_column, first_entry
      end
    end

    def round_time_booking_total(entries, total)
      projects = entries.entries.map(&:project).uniq
      return if projects.length > 1
      return total unless Chronos::Settings[:round_sums_only, project: projects.first]
      Chronos::DateTimeCalculations.in_hours(Chronos::DateTimeCalculations.round_interval total.hours, project: projects.first)
    end
  end
end
