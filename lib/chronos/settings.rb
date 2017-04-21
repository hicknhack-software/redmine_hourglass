module Chronos
  module Settings
    class << self
      def settings(project: nil, merged: true)
        settings = Setting["plugin_#{Chronos.plugin_name}"]
        if project
          project_id = project.is_a?(Project) ? project.id : project
          project_settings = settings[:projects] && settings[:projects]["#{project_id}".to_sym] || {}
          return settings.except(:projects).merge project_settings if merged
          project_settings
        else
          return settings.except :projects if merged
          settings
        end
      end

      def save_settings(settings_params, project: nil)
        new_settings = if project
                         settings(merged: false).tap do |settings|
                           settings[:projects] ||= {}
                           settings[:projects]["#{project.id}".to_sym] = settings(project: project, merged: false).merge(settings_params.symbolize_keys).compact
                         end
                       else
                         settings(merged: false).merge settings_params.symbolize_keys
                       end
        Setting.send "plugin_#{Chronos.plugin_name}=", new_settings
      end
    end
  end
end
