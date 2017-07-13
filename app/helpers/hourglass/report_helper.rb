module Hourglass
  module ReportHelper
    def report_column_map
      @report_column_map ||= {
          date: [:start, :stop],
          description: [:activity, :issue, :comments, :project, :fixed_version],
          duration: [:hours, :start, :stop]
      }
    end

    def combined_column_names(column)
      report_column_map.select { |_key, array| array.include? column.name }.keys
    end

    def combined_columns
      columns = []
      @query.columns.each do |column|
        combined_names = combined_column_names(column)
        columns.push column if combined_names.empty?
        combined_names.reject { |name| columns.find { |col| col.name == name } }.each do |name|
          columns.push QueryColumn.new name
        end
      end
      columns.sort_by! do |column|
        report_column_map.keys.index(column.name) || Float::INFINITY
      end
    end

    def description_content(entry)
      output = ActiveSupport::SafeBuffer.new
      if entry.issue.present?
        output.concat entry.activity
        output.concat entry.issue
      else
        output.concat [entry.activity, entry.comments].compact.join(': ')
      end
      output.concat(content_tag :div, class: 'project' do
        [entry.project, entry.fixed_version].compact.join(' / ')
      end)
      output
    end

    def duration_content(entry)
      output = ActiveSupport::SafeBuffer.new
      output.concat localized_hours_in_units entry.hours
      output.concat(content_tag :div, class: 'start-stop' do
        [format_time(entry.start, false), format_time(entry.stop, false)].compact.join(' - ')
      end)
      output
    end
  end
end
