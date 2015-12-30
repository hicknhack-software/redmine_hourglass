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
  end
end
