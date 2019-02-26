class HourglassProjectsController < ApplicationController
  include BooleanParsing

  def settings
    find_project
    deny_access unless User.current.allowed_to? :select_project_modules, @project

    Hourglass::Settings[project: @project] = settings_params
    flash[:notice] = l(:notice_successful_update)
    redirect_to settings_project_path @project, tab: Hourglass::PLUGIN_NAME
  end

  private
  def settings_params
    p = params[:settings].transform_values(&:presence)
    p = parse_boolean [:round_default, :round_sums_only], p
    p = parse_float [:round_minimum, :round_carry_over_due], p
    parse_int [:round_limit], p
  end
end
