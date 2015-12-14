module Chronos
  module ApplicationHelper
    def authorize_globally_for(controller, action)
      User.current.allowed_to_globally? controller: controller, action: action
    end

    def issue_label_for(issue)
      "##{issue.id} #{issue.subject}" if issue
    end

    def projects_for_project_select(selected = nil)
      projects = User.current.projects.has_module('redmine_chronos')
      project_tree_options_for_select projects, selected: selected
    end

    def activity_collection(project = nil)
      project.present? ? project.activities : TimeEntryActivity.shared.active
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

    def sidebar_queries
      @sidebar_queries ||= query_class.where(project: [nil, @project]).order(name: :asc)
    end

    def chart_data
      data = Array.new
      ticks = Array.new
      tooltips = Array.new

      if @chart_query.valid?
        hours_per_date = @chart_query.hours_by_group
        dates = hours_per_date.keys.sort
        (dates.first..dates.last).map do |date_string|
          hours = hours_per_date[date_string]
          data.push hours
          time_array = Chronos::DateTimeCalculations.format_hours hours
          tooltips.push "#{date_string}, #{time_array[0]}#{t('chronos.ui.chart.hour_sign')} #{time_array[1]}#{t('chronos.ui.chart.minute_sign')}"

          # to get readable labels, we have to blank out some of them if there are to many
          # only set 8 labels and set the other blank
          gap = (hours_per_date.length / 8).ceil
          if gap == 0 || hours_per_date.length % gap == 0
            ticks.push date_string
          else
            ticks.push ''
          end
        end
      end
      [data, ticks, tooltips]
    end
  end
end
