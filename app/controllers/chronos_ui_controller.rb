class ChronosUiController < ApplicationController
  include SortHelper
  include QueryConcern
  include ListConcern
  include AuthorizationConcern
  include ChronosUi::Overview
  include ChronosUi::TimeLogs
  include ChronosUi::TimeBookings
  include ChronosUi::TimeTrackers

  helper QueriesHelper
  helper IssuesHelper
  helper SortHelper
  helper Chronos::ApplicationHelper
  helper Chronos::UiHelper
  helper Chronos::ListHelper
  helper Chronos::ReportHelper

  before_filter :authorize_global

  private
  def authorize_foreign
    return super if block_given?
    super do
      render_403
    end
  end
end
