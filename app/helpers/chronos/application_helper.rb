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
      project_tree_options_for_select projects, selected: selected, include_blank: true
    end

    def activity_collection(project = nil)
      project.present? ? project.activities : TimeEntryActivity.shared.active
    end

    def grouped_entry_list(entries, query, count_by_group)
      previous_group, first = false, true
      entries.each do |entry|
        group_name = group_count = nil
        if query.grouped? && ((group = query.group_by_column.value(entry)) != previous_group || first)
          if group.blank? && group != false
            group_name = "(#{l(:label_blank_value)})"
          else
            group_name = column_content(query.group_by_column, entry)
          end
          group_name ||= ''
          group_count = count_by_group[group]
        end
        yield entry, group_name, group_count
        previous_group, first = group, false
      end
    end

    def sidebar_queries
      @sidebar_queries ||= query_class.order(name: :asc)
    end
  end
end
