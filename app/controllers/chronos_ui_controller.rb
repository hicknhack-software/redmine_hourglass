class ChronosUiController < ApplicationController
  helper QueriesHelper
  helper IssuesHelper
  helper SortHelper
  helper Chronos::ApplicationHelper
  helper Chronos::UiHelper
  helper Chronos::ListHelper
  helper Chronos::ReportHelper

  before_action :authorize_global

  include AuthorizationConcern
  include SortHelper
  include QueryConcern
  include ListConcern

  include ChronosUi::Overview
  include ChronosUi::TimeLogs
  include ChronosUi::TimeBookings
  include ChronosUi::TimeTrackers

  private
  def authorize_foreign
    super { render_403 }
  end
end
