class HourglassProjectsController < ApplicationController
  def settings
    find_project
    deny_access unless User.current.allowed_to? :select_project_modules, @project

    settings = params[:settings].transform_values(&:presence)
    settingsValidation = Hourglass::SettingsValidation.new settings
    if settingsValidation.valid?
      Hourglass::Settings[project: @project] = settings
      flash[:notice] = l(:notice_successful_update)
      redirect_to settings_project_path @project, tab: Hourglass::PLUGIN_NAME
    else
      flash[:error] = settingsValidation.errors.full_messages.to_sentence
      redirect_to settings_project_path @project, tab: Hourglass::PLUGIN_NAME
    end
  end
end
