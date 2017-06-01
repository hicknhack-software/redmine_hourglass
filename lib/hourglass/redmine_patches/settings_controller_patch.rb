module Hourglass
  module RedminePatches
    module SettingsControllerPatch
      extend ActiveSupport::Concern

      included do
        include BooleanParsing
        alias_method_chain :plugin, :hourglass
      end

      def plugin_with_hourglass
        return plugin_without_hourglass unless request.post? && params[:id] == Hourglass::PLUGIN_NAME.to_s

        Hourglass::Settings[] = hourglass_settings_params
        flash[:notice] = l(:notice_successful_update)
        redirect_to plugin_settings_path Hourglass::PLUGIN_NAME
      end

      private
      def hourglass_settings_params
        boolean_keys = [:round_default, :round_sums_only, :global_tracker]
        parse_boolean boolean_keys, params[:settings].transform_values(&:presence).select { |key, value| boolean_keys.include?(key) || !value.nil? }
      end
    end
  end
end
