module Chronos
  module UiHelper
    def render_main_menu(project)
      render_menu :chronos_menu
    end

    def display_main_menu?(project)
      Redmine::MenuManager.items(:chronos_menu).children.present?
    end

    def sidebar_queries
      @sidebar_queries ||= query_class.where(project: [nil, @project]).order(name: :asc)
    end

    def column_content(column, entry, use_html = true)
      content_method = "#{column.name}_content".to_sym
      if respond_to? content_method
        send content_method, entry
      elsif use_html
        super column, entry
      else
        csv_content column, entry
      end
    end

    def format_date(time)
      return nil unless time
      zone = User.current.time_zone
      local = zone ? time.in_time_zone(zone) : (time.utc? ? time.localtime : time)
      super local.to_date
    end
  end
end
