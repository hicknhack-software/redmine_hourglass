class HourglassImportController < ApplicationController
  def redmine_time_tracker_plugin
    Hourglass::RedmineTimeTrackerImport.start!

    flash[:notice] = I18n::t('hourglass.settings.import.success.redmine_time_tracker')
  rescue => e
    messages = [e.message] + e.backtrace
    Rails.logger.error messages.join("\n")
    flash[:error] = I18n::t('hourglass.settings.import.error.redmine_time_tracker')
  ensure
    redirect_to plugin_settings_path Hourglass::PLUGIN_NAME
  end
end
