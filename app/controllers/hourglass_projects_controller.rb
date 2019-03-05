class HourglassProjectsController < ApplicationController
  helper :application

  def settings
    find_project
    deny_access unless User.current.allowed_to? :select_project_modules, @project

    @settings = Hourglass::ProjectSettings.load(@project)
    if request.post?
      if @settings.update(hourglass_settings_params)
        flash[:notice] = l(:notice_successful_update)
        render js: "window.location='#{settings_project_path @project, tab: Hourglass::PLUGIN_NAME}'"
        return
      end
    end
  end

  private
  def hourglass_settings_params
    params.require(:hourglass_project_settings).permit(:round_sums_only, :round_minimum, :round_limit,
                                                      :round_default, :round_carry_over_due)
  end
end
