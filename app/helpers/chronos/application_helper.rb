module Chronos
  module ApplicationHelper
    def authorize_globally_for(controller, action)
      User.current.allowed_to_globally? controller: controller, action: action
    end

    def projects_for_project_select
      projects = User.current.projects.has_module('redmine_chronos')
      project_tree_options_for_select projects, selected: @time_tracker.project, include_blank: t('chronos.ui.page_overview.time_tracker_control.label_project_none')
    end
  end
end
