class HourglassUiController < ApplicationController
  helper QueriesHelper
  helper IssuesHelper
  helper SortHelper
  helper Hourglass::ApplicationHelper
  helper Hourglass::UiHelper
  helper Hourglass::ListHelper
  helper Hourglass::ChartHelper
  helper Hourglass::ReportHelper

  before_action :authorize_global

  include AuthorizationConcern
  include SortHelper
  include QueryConcern
  include ListConcern

  include HourglassUi::Overview
  include HourglassUi::TimeLogs
  include HourglassUi::TimeBookings
  include HourglassUi::TimeTrackers

  private
  def authorize_foreign
    super { render_403 }
  end
end
