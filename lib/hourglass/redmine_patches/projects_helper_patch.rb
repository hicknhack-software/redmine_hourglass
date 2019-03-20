module Hourglass
  module RedminePatches
    module ProjectsHelperPatch
      extend ActiveSupport::Concern

      included do
        alias_method :project_settings_tabs_without_hourglass, :project_settings_tabs
        alias_method :project_settings_tabs, :project_settings_tabs_with_hourglass
      end

      if Rails.version < "5"
        def project_settings_tabs_with_hourglass
          project_settings_tabs_without_hourglass.tap &method(:hourglass_tab)
        end
      else
        def project_settings_tabs
          super.tap &method(:hourglass_tab)
        end
      end

      private

      def hourglass_tab(tabs)
        @settings = Hourglass::ProjectSettings.load(@project)
        tabs << { name: Hourglass::PLUGIN_NAME.to_s, partial: 'hourglass_projects/hourglass_settings',
          label: 'hourglass.project_settings.title' } if @project.module_enabled?(Hourglass::PLUGIN_NAME) &&
            User.current.allowed_to?(:select_project_modules, @project)
      end
    end
  end
end
