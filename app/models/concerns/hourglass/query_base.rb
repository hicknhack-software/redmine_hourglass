module Hourglass::QueryBase
  extend ActiveSupport::Concern

  included do
    self.queried_class = name.gsub('Query', '').constantize

    # copied from issue query, without the view_issues right check
    scope :visible, lambda { |*args|
      user = args.shift || User.current
      scope = joins("LEFT OUTER JOIN #{Project.table_name} ON #{table_name}.project_id = #{Project.table_name}.id").
          where("#{table_name}.project_id IS NULL")

      if user.admin?
        scope.where("#{table_name}.visibility <> ? OR #{table_name}.user_id = ?", Query::VISIBILITY_PRIVATE, user.id)
      elsif user.memberships.any?
        scope.where("#{table_name}.visibility = ?" +
                        " OR (#{table_name}.visibility = ? AND #{table_name}.id IN (" +
                        "SELECT DISTINCT q.id FROM #{table_name} q" +
                        " INNER JOIN #{table_name_prefix}queries_roles#{table_name_suffix} qr on qr.query_id = q.id" +
                        " INNER JOIN #{MemberRole.table_name} mr ON mr.role_id = qr.role_id" +
                        " INNER JOIN #{Member.table_name} m ON m.id = mr.member_id AND m.user_id = ?" +
                        " WHERE q.project_id IS NULL OR q.project_id = m.project_id))" +
                        " OR #{table_name}.user_id = ?",
                    Query::VISIBILITY_PUBLIC, Query::VISIBILITY_ROLES, user.id, user.id)
      elsif user.logged?
        scope.where("#{table_name}.visibility = ? OR #{table_name}.user_id = ?", Query::VISIBILITY_PUBLIC, user.id)
      else
        scope.where("#{table_name}.visibility = ?", Query::VISIBILITY_PUBLIC)
      end
    }
  end

  class_methods do
    def set_available_columns(columns)
      self.available_columns = columns.map do |name, options|
        QueryColumn.new name, options
      end
    end
  end

  def initialize(attributes = nil)
    super
    self.filters ||= {}
  end

  def build_from_params(params)
    super
    self.totalable_names = self.default_totalable_names unless params[:t] || (params[:query] && params[:query][:totalable_names])
    self
  end

  def queried_class
    self.class.queried_class
  end

  def base_scope
    queried_class.where statement
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

  def default_totalable_names
    @default_totalable_names ||= [:hours]
  end

  def count_by_group
    grouped_query do |scope|
      scope.count
    end
  end

  def totals_by_group
    totalable_columns.each_with_object({}) do |column, result|
      total_by_group_for(column).each do |group, total|
        result[group] ||= {}
        result[group][column] = total
      end
    end
  end

  def column_value(column, entry)
    content_method = "#{column.name}_value".to_sym
    if respond_to? content_method
      send content_method, entry
    else
      column.value entry
    end
  end

  def date_value(entry)
    entry.start.to_date
  end

  def sql_for_date_field(field, operator, value)
    sql_for_field(field, operator, value, queried_class.table_name, 'start')
  end

  def sql_for_field(field, operator, value, db_table, db_field, is_custom_filter=false)
    sql = ''
    case operator
      when 'w+lw'
        # = this and last week
        first_day_of_week = l(:general_first_day_of_week).to_i
        day_of_week = Date.today.cwday
        days_ago = (day_of_week >= first_day_of_week ? day_of_week - first_day_of_week : day_of_week + 7 - first_day_of_week)
        sql = relative_date_clause(db_table, db_field, -days_ago - 7, -days_ago + 6, is_custom_filter)
      when 'q'
        # = current quarter
        date = User.current.today
        sql = date_clause(db_table, db_field, date.beginning_of_quarter, date.end_of_quarter, is_custom_filter)
      else
        sql = super
    end
    sql
  end

  private
  def add_date_filter
    add_available_filter 'date', type: :date
  end

  def add_comments_filter
    add_available_filter 'comments', type: :text
  end

  def add_user_filter
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

  def add_project_filter
    values = []
    if User.current.logged? && User.current.memberships.any?
      values << ["<< #{l(:label_my_projects).downcase} >>", 'mine']
    end
    values += all_projects_values
    add_available_filter 'project_id', type: :list, values: values if values.any?
  end

  def add_sub_project_filter
    sub_projects = project.descendants.visible.to_a
    values = sub_projects.collect { |s| [s.name, s.id.to_s] }
    add_available_filter 'subproject_id', type: :list_subprojects, values: values if values.any?
  end

  def add_issue_filter
    issues = Issue.visible.all
    values = issues.collect { |s| [s.subject, s.id.to_s] }
    add_available_filter 'issue_id', type: :list, values: values if values.any?
    add_available_filter 'issue_subject', type: :text if issues.any?
  end

  def add_activity_filter
    activities = project ? project.activities : TimeEntryActivity.shared
    values = activities.map { |a| [a.name, a.id.to_s] }
    add_available_filter 'activity_id', type: :list, values: values if values.any?
  end

  def add_fixed_version_filter
    versions = if project
                 project.shared_versions.to_a
               else
                 Version.visible.where(sharing: 'system').to_a
               end
    values = versions.uniq.sort.collect { |s| ["#{s.project.name} - #{s.name}", s.id.to_s] }
    add_available_filter 'fixed_version_id', type: :list_optional, values: values
  end
end
