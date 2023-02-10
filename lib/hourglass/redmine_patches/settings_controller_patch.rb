module Hourglass
  module RedminePatches
    module SettingsControllerPatch
      extend ActiveSupport::Concern

      included do
        alias_method :plugin_without_hourglass, :plugin
        alias_method :plugin, :plugin_with_hourglass
      end

      def plugin_with_hourglass
        return plugin_without_hourglass unless params[:id] == Hourglass::PLUGIN_NAME.to_s
        hourglass_edit_update
      end

      private

      def hourglass_edit_update
        @plugin = Redmine::Plugin.find(params[:id])
        @partial = @plugin.settings[:partial]
        @settings = Hourglass::GlobalSettings.new
        if request.post?
          if @settings.update(hourglass_settings_params)
            flash[:notice] = l(:notice_successful_update)
            redirect_to plugin_settings_path Hourglass::PLUGIN_NAME
            return
          end
        end
        render 'settings/global_settings'
      end

      def hourglass_settings_params
        params.require(:hourglass_global_settings).permit(:round_sums_only, :round_minimum, :round_limit,
                                                          :round_default, :round_carry_over_due, :report_title,
                                                          :report_logo_url, :report_logo_width, :global_tracker,
                                                          :clamp_limit)
      end
    end
  end
end
