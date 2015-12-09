require 'rake'

class ChronosImportController < ApplicationController
  def redmine_time_tracker_plugin
    load File.expand_path(File.join(File.dirname(__FILE__), '../../lib/tasks/import.rake'))

    Rake::Task.define_task(:environment)
    Rake::Task['redmine:plugins:chronos:import_redmine_time_tracker'].invoke

    flash[:notice] = I18n::t('chronos.settings.import.time_tracker_plugin_success')
  rescue
    flash[:error] = I18n::t('chronos.settings.import.time_tracker_plugin_error')
  ensure
    redirect_to plugin_settings_path(:redmine_chronos)
  end
end
