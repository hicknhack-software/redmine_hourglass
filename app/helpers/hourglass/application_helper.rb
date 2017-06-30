module Hourglass
  module ApplicationHelper
    def hourglass_asset_paths(type, sources)
      options = sources.extract_options!
      if options[:plugin] == Hourglass::PLUGIN_NAME && Rails.env.production?
        plugin = options.delete(:plugin)
        sources.map! do |source|
          extname = compute_asset_extname source, options.merge(type: type)
          source = "#{source}#{extname}" if extname.present?
          source = File.join Hourglass::Assets.asset_directory_map[type], source
          "/plugin_assets/#{plugin}/#{Hourglass::Assets.manifest.assets[source]}"
        end
      end
      sources.push options
    end

    def javascript_include_tag(*sources)
      super *hourglass_asset_paths(:javascript, sources)
    end

    def stylesheet_link_tag(*sources)
      super *hourglass_asset_paths(:stylesheet, sources)
    end

    def form_field(field, form, object, options = {})
      render partial: "hourglass_ui/forms/fields/#{field}", locals: {form: form, entry: object}.merge(options)
    end

    def issue_label_for(issue)
      "##{issue.id} #{issue.subject}" if issue
    end

    def projects_for_project_select(selected = nil)
      projects = User.current.projects.allowed_to_one_of *(Hourglass::AccessControl.permissions_from_action(controller: 'hourglass/time_logs', action: 'book') + Hourglass::AccessControl.permissions_from_action(controller: 'hourglass/time_bookings', action: 'update')).flatten
      project_tree_options_for_select projects, selected: selected do |project|
        {data: {
            round_default: Hourglass::Settings[:round_default, project: project],
            round_sums_only: Hourglass::Settings[:round_sums_only, project: project]
        }}
      end
    end

    def activity_collection(project = nil)
      project.present? ? project.activities : TimeEntryActivity.shared.active
    end

    def user_collection(project = nil)
      project.present? ? project.users : User.active
    end

    def localized_hours_in_units(hours)
      h, min = Hourglass::DateTimeCalculations.hours_in_units hours || 0
      "#{h}#{t('hourglass.ui.chart.hour_sign')} #{min}#{t('hourglass.ui.chart.minute_sign')}"
    end

    def in_user_time_zone(time)
      zone = User.current.time_zone
      if zone
        time.in_time_zone zone
      else
        time.utc? ? time.localtime : time
      end
    end

    def css_classes(*args)
      args.compact.join(' ')
    end

    def convert_format_identifier(format)
      format.gsub /%[HIMp]/,
                  '%H' => 'HH',
                  '%I' => 'hh',
                  '%M' => 'mm',
                  '%p' => 'TT',
                  '%P' => 'tt'
    end
  end
end
