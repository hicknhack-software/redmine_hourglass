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

    def sidebar_queries
      @sidebar_queries ||= query_class.where(project: [nil, @project]).order(name: :asc)
    end

    def localized_hours_in_units(hours)
      h, min = Chronos::DateTimeCalculations.hours_in_units hours || 0
      "#{h}#{t('chronos.ui.chart.hour_sign')} #{min}#{t('chronos.ui.chart.minute_sign')}"
    end
  end
end
