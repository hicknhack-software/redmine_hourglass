class ChronosImportController < ApplicationController
  def redmine_time_tracker_plugin
    ChronosImport::RedmineTimeTracker.import!

    flash[:notice] = I18n::t('chronos.settings.import.time_tracker_plugin_success')
  rescue => e
    puts e
    flash[:error] = I18n::t('chronos.settings.import.time_tracker_plugin_error')
  ensure
    redirect_to plugin_settings_path(:redmine_chronos)
  end
end
