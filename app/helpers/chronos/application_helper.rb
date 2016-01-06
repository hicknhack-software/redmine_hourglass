module Chronos
  module ApplicationHelper
    def chronos_asset_paths(type, sources)
      options = sources.extract_options!
      if options[:plugin] == 'redmine_chronos' && Rails.env.production?
        plugin = options.delete(:plugin)
        sources.map! do |source|
          extname = compute_asset_extname source, options.merge(type: type)
          source = "#{source}#{extname}" if extname.present?
          "/plugin_assets/#{plugin}/#{Chronos::Assets.manifest.assets[source]}"
        end
      end
      sources.push options
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

    def form_field(field, form, object, options = {})
      render partial: "chronos_ui/forms/fields/#{field}", locals: {form: form, entry: object}.merge(options)
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

    def localized_hours_in_units(hours)
      h, min = Chronos::DateTimeCalculations.hours_in_units hours || 0
      "#{h}#{t('chronos.ui.chart.hour_sign')} #{min}#{t('chronos.ui.chart.minute_sign')}"
    end
  end
end
