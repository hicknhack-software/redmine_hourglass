module Hourglass
  module UiHelper
    def title_for_query_view
      title @query.persisted? ? h(@query.name) : t("hourglass.ui.#{action_name}.title")
    end

    def render_main_menu(project)
      render_menu :hourglass_menu
    end

    def display_main_menu?(project)
      Redmine::MenuManager.items(:hourglass_menu).children.present?
    end

    def query_links(title, queries)
      params.delete :set_filter
      super
    end

    def sidebar_queries
      @sidebar_queries ||= query_class.visible.where(project: [nil, @project]).order(name: :asc)
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
      super in_user_time_zone(time).to_date
    end
  end
end
