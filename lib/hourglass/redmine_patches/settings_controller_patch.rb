module Hourglass
  module RedminePatches
    module SettingsControllerPatch
      extend ActiveSupport::Concern

      included do
        alias_method_chain :plugin, :hourglass
      end

      def plugin_with_hourglass
        return plugin_without_hourglass unless request.post? && params[:id] == Hourglass::PLUGIN_NAME.to_s

        settings = params[:settings].transform_values(&:presence)
        settingsValidation = Hourglass::SettingsValidation.new settings
        settingsValidation.global_settings = true
        if settingsValidation.valid?
          Hourglass::Settings[] = settings
          flash[:notice] = l(:notice_successful_update)
          redirect_to plugin_settings_path Hourglass::PLUGIN_NAME
        else
          flash[:error] = settingsValidation.errors.full_messages.to_sentence
          redirect_to plugin_settings_path Hourglass::PLUGIN_NAME
        end
      end
    end
  end
end
