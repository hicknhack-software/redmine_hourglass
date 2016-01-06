class ChronosImportController < ApplicationController
  def redmine_time_tracker_plugin
    Chronos::RedmineTimeTrackerImport.start!

    flash[:notice] = I18n::t('chronos.settings.import.success.redmine_time_tracker')
  rescue => e
    puts e
    flash[:error] = I18n::t('chronos.settings.import.error.redmine_time_tracker')
  ensure
    redirect_to plugin_settings_path Chronos.plugin_name
  end
end
