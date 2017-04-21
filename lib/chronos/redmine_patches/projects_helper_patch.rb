module Chronos
  module RedminePatches
    module ProjectsHelperPatch
      extend ActiveSupport::Concern

      def project_settings_tabs
        super + [{name: Chronos.plugin_name.to_s, action: :select_project_modules, partial: 'projects/chronos_settings', label: 'chronos.project_settings.title'}].select { |tab| @project.module_enabled?(Chronos.plugin_name) && User.current.allowed_to?(tab[:action], @project) }
      end
    end
  end
end
