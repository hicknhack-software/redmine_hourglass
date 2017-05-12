module Chronos
  module RedminePatches
    module ProjectsHelperPatch
      extend ActiveSupport::Concern

      def project_settings_tabs
        super.tap do |tabs|
          tabs << {name: Chronos::PLUGIN_NAME.to_s, partial: 'projects/chronos_settings', label: 'chronos.project_settings.title'} if @project.module_enabled?(Chronos::PLUGIN_NAME) && User.current.allowed_to?(:select_project_modules, @project)
        end
      end
    end
  end
end
