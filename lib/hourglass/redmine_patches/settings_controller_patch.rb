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
        p = params[:settings].transform_values(&:presence)
        p = parse_boolean [:round_default, :round_sums_only, :global_tracker], p
        p = parse_float [:round_minimum, :round_carry_over_due], p
        parse_int [:round_limit, :report_logo_width], p
      end
    end
  end
end
