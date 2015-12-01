module Chronos
  class TimeLogQuery < Query
    self.queried_class = TimeLog

    self.available_columns = [
        QueryColumn.new(:comments),
        QueryColumn.new(:user, sortable: lambda { User.fields_for_order_statement }, groupable: true),
        QueryColumn.new(:start, sortable: "#{TimeLog.table_name}.start", default_order: 'desc', groupable: true),
        QueryColumn.new(:stop, sortable: "#{TimeLog.table_name}.stop", default_order: 'desc', groupable: true)
    ]

    def initialize(attributes=nil, *args)
      super attributes
      self.filters ||= {}
    end

    def initialize_available_filters
      add_available_filter 'comments', type: :text

      principals = []
      if project
        principals += project.principals.visible.sort
        unless project.leaf?
          subprojects = project.descendants.visible.to_a
          if subprojects.any?
            add_available_filter "subproject_id",
                                 :type => :list_subprojects,
                                 :values => subprojects.collect{|s| [s.name, s.id.to_s] }
            principals += Principal.member_of(subprojects).visible
          end
        end
      else
        if all_projects.any?
          principals += Principal.member_of(all_projects).visible
        end
      end
      principals.uniq!
      principals.sort!
      users = principals.select {|p| p.is_a?(User)}

      users_values = []
      users_values << ["<< #{l(:label_me)} >>", "me"] if User.current.logged?
      users_values += users.collect{|s| [s.name, s.id.to_s] }
      add_available_filter("user_id",
                           :type => :list_optional, :values => users_values
      ) unless users_values.empty?
    end

    def default_columns_names
      @default_columns_names ||= [:start, :stop, :user, :comments]
    end

    def is_private?
      visibility == VISIBILITY_PRIVATE
    end

    def is_public?
      !is_private?
    end

    def results_scope(options = {})
      order_option = [group_by_sort_order, options[:order]].flatten.reject(&:blank?)

      TimeLog.
          joins(:user).
          where(statement).
          order(order_option).
          joins(joins_for_order_statement(order_option.join(',')))
    end

    def count_by_group
      r = nil
      if grouped?
        begin
          r = TimeLog.
              joins(:user).
              where(statement).
              joins(joins_for_order_statement(group_by_statement)).
              group(group_by_statement).
              count
        rescue ActiveRecord::RecordNotFound
          r = {nil => TimeLog.joins(:user).where(statement).count}
        end
        c = group_by_column
        if c.is_a?(QueryCustomFieldColumn)
          r = r.keys.inject({}) {|h, k| h[c.custom_field.cast_value(k)] = r[k]; h}
        end
      end
      r
    rescue ::ActiveRecord::StatementInvalid => e
      raise Query::StatementInvalid.new(e.message)
    end
  end
end
