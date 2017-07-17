module Hourglass
  module UiHelper
    def title_for_query_view
      title @query.persisted? ? h(@query.name) : t("hourglass.ui.#{action_name}.title")
    end

    def render_main_menu(_project)
      render_menu :hourglass_menu
    end

    def display_main_menu?(_project)
      Redmine::MenuManager.items(:hourglass_menu).children.present?
    end

    def query_links(title, queries)
      params.delete :set_filter
      super
    end

    unless Hourglass.redmine_has_advanced_queries?
      def render_sidebar_queries(_klass, _project)
        super()
      end

      def sidebar_queries
        @sidebar_queries ||= query_class.visible.where(project: [nil, @project]).order(name: :asc)
      end
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

    def date_time_format
      date = Setting.date_format.blank? ? I18n.t('date.formats.default') : Setting.date_format
      time = Setting.time_format.blank? ? I18n.t('time.formats.time') : Setting.time_format
      "#{date} #{time}"
    end

    def utc_offset
      user_time_zone = User.current.time_zone
      return user_time_zone.now.formatted_offset if user_time_zone
      time = Time.now
      return time.localtime.formatted_offset if time.utc?
      time.formatted_offset
    end

    def date_strings_lookup(key)
      I18n.t(key, scope: :date).compact.to_json.html_safe
    end
  end
end
