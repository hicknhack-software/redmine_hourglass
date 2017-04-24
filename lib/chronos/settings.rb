module Chronos
  module Settings
    class << self
      def defaults
        {
            global_tracker: true,
            report_title: 'Report',
            report_logo_url: '',
            report_logo_width: '150',
            round_minimum: '0.25',
            round_limit: '50',
            round_carry_over_due: '12',
            round_default: false
        }
      end

      def global
        get.call
      end

      def project(project_or_project_id)
        projects = get.call[:projects] or return {}
        projects[project_id_key project_or_project_id] || {}
      end

      # Use it like this:
      #   Get multiple global settings
      #     Chronos::Settings[]
      #
      #   Get one global setting
      #     Chronos::Settings[:setting]
      #
      #   Get multiple project settings
      #     Chronos::Settings[project: 1]
      #
      #   Get one project setting
      #     Chronos::Settings[:setting, project: 1]
      def [](key = nil, project: nil)
        settings = get.call.except(:projects)
        settings = settings.merge project project if project
        return settings[key] if key
        settings
      end

      # Use it like this:
      #   Set multiple global settings
      #     Chronos::Settings[] = {setting: 1, setting2: 2}
      #
      #   Set one global setting
      #     Chronos::Settings[:setting] = 1
      #
      #   Set multiple project settings
      #     Chronos::Settings[project: 1] = {setting: 1, setting2: 2}
      #
      #   Set one project setting
      #     Chronos::Settings[:setting, project: 1] = 1
      def []=(*args)
        project, new_settings = parse_assign_params *args.reverse

        settings = get.call
        if project
          settings[:projects] ||= {}
          if new_settings
            settings[:projects][project_id_key project] = project(project).merge(new_settings).compact
          else
            settings[:projects].delete project_id_key project
          end
        else
          settings.merge! new_settings
        end
        set.call settings
      end

      private
      def parse_assign_params(new_settings = nil, options = nil, key = nil)
        key, options = [options, nil] if key == nil && options.is_a?(Symbol)
        new_settings = {"#{key}": new_settings} if key.is_a?(Symbol)
        project = options[:project] if options.is_a? Hash

        new_settings = new_settings.deep_symbolize_keys if new_settings.is_a? Hash
        new_settings ||= {} unless project

        [project, new_settings]
      end

      def project_id_key(project_or_project_id)
        project_id = project_or_project_id.is_a?(Project) ? project_or_project_id.id : project_or_project_id
        "#{project_id}".to_sym
      end

      def get
        Setting.method redmine_method_name.to_sym
      end

      def set
        Setting.method "#{redmine_method_name}=".to_sym
      end

      def redmine_method_name
        "plugin_#{Chronos.plugin_name}"
      end
    end
  end
end
