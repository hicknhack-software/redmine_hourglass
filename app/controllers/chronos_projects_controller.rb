class ChronosProjectsController < ApplicationController
  include BooleanParsing

  def settings
    find_project
    deny_access unless User.current.allowed_to? :select_project_modules, @project

    Chronos::Settings[project: @project] = settings_params
    flash[:notice] = l(:notice_successful_update)
    redirect_to settings_project_path @project, tab: Chronos.plugin_name
  end

  private
  def settings_params
    boolean_keys = [:round_default, :round_sums_only]
    parse_boolean boolean_keys, params[:settings].transform_values(&:presence)
  end
end
