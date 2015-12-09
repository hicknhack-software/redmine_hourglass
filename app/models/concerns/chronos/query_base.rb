module Chronos::QueryBase
  extend ActiveSupport::Concern

  included do
    def initialize(attributes = nil, *args)
      super attributes
      self.filters ||= {}
    end

    def is_private?
      visibility == Query::VISIBILITY_PRIVATE
    end

    def is_public?
      !is_private?
    end

    def results_scope(options = {})
      order_option = [group_by_sort_order, options[:order]].flatten.reject(&:blank?)
      base_scope.
          order(order_option).
          joins(joins_for_order_statement(order_option.join(',')))
    end

    def count_by_group
      grouped_query do |scope|
        scope.count
      end
    end

    private
    def add_users_filter
      principals = []
      if project
        principals += project.principals.visible.sort
        unless project.leaf?
          sub_projects = project.descendants.visible.to_a
          principals += Principal.member_of(sub_projects).visible
        end
      else
        if all_projects.any?
          principals += Principal.member_of(all_projects).visible
        end
      end
      principals.uniq!
      principals.sort!
      users = principals.select { |p| p.is_a?(User) }
      values = []
      values << ["<< #{l(:label_me)} >>", 'me'] if User.current.logged?
      values += users.collect { |s| [s.name, s.id.to_s] }
      add_available_filter 'user_id', type: :list, values: values if values.any?
    end

    def add_projects_filter
      values = []
      if User.current.logged? && User.current.memberships.any?
        values << ["<< #{l(:label_my_projects).downcase} >>", 'mine']
      end
      values += all_projects_values
      add_available_filter 'project_id', type: :list, values: values if values.any?
    end

    def add_sub_projects_filter
      sub_projects = project.descendants.visible.to_a
      values = sub_projects.collect { |s| [s.name, s.id.to_s] }
      add_available_filter 'subproject_id', type: :list_subprojects, values: values if values.any?
    end

    def add_issues_filter
      issues = Issue.visible.all
      values = issues.collect { |s| [s.subject, s.id.to_s] }
      add_available_filter 'issue', type: :list, values: values if values.any?
      add_available_filter 'issue_subject', type: :text if issues.any?
    end

    def add_activities_filter
      activities = project ? project.activities : TimeEntryActivity.shared
      values = activities.map { |a| [a.name, a.id.to_s] }
      add_available_filter 'activity_id', type: :list, values: values if values.any?
    end

    def add_fixed_versions_filter
      versions = if project
        project.shared_versions.to_a
      else
        Project.visible.includes(:versions).all.flat_map { |project| project.shared_versions.all }
      end
      values = versions.uniq.sort.collect { |s| ["#{s.project.name} - #{s.name}", s.id.to_s] }
      add_available_filter 'fixed_version_id', type: :list_optional, values: values if values.any?
    end
  end
end