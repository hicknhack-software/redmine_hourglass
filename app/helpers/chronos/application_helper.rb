module Chronos
  module ApplicationHelper
    def chronos_asset_paths(type, sources)
      options = sources.extract_options!
      if options[:plugin] == Chronos::PLUGIN_NAME && Rails.env.production?
        plugin = options.delete(:plugin)
        sources.map! do |source|
          extname = compute_asset_extname source, options.merge(type: type)
          source = "#{source}#{extname}" if extname.present?
          "/plugin_assets/#{plugin}/#{Chronos::Assets.manifest.assets[source]}"
        end
      end
      sources.push options
    end

    def render_flash_messages
      render partial: 'chronos_ui/shared/flash_messages'
    end

    def javascript_include_tag(*sources)
      super *chronos_asset_paths(:javascript, sources)
    end

    def stylesheet_link_tag(*sources)
      super *chronos_asset_paths(:stylesheet, sources)
    end

    def authorize_globally_for(controller, action)
      User.current.allowed_to_globally? controller: controller, action: action
    end

    def allowed_to?(controller, action, context)
      User.current.allowed_to?({controller: controller, action: action}, context)
    end

    def form_field(field, form, object, options = {})
      render partial: "chronos_ui/forms/fields/#{field}", locals: {form: form, entry: object}.merge(options)
    end

    def issue_label_for(issue)
      "##{issue.id} #{issue.subject}" if issue
    end

    def projects_for_project_select(selected = nil)
      projects = User.current.projects.allowed_to_one_of *Chronos::AccessControl.permissions_from_action(controller: 'chronos/time_logs', action: 'book')
      project_tree_options_for_select projects, selected: selected do |project|
        {data: {
            round_default: Chronos::Settings[:round_default, project: project],
            round_sums_only: Chronos::Settings[:round_sums_only, project: project]
        }}
      end
    end

    def activity_collection(project = nil)
      project.present? ? project.activities : TimeEntryActivity.shared.active
    end

    def localized_hours_in_units(hours)
      h, min = Chronos::DateTimeCalculations.hours_in_units hours || 0
      "#{h}#{t('chronos.ui.chart.hour_sign')} #{min}#{t('chronos.ui.chart.minute_sign')}"
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
