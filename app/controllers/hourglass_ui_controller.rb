class HourglassUiController < ApplicationController
  helper QueriesHelper
  helper IssuesHelper
  helper SortHelper
  helper Hourglass::ApplicationHelper
  helper Hourglass::UiHelper
  helper Hourglass::ListHelper
  helper Hourglass::ChartHelper
  helper Hourglass::ReportHelper

  before_action :authorize_global, except: [:context_menu, :api_docs]
  before_action :require_login, only: [:context_menu, :api_docs]

  include AuthorizationConcern
  include SortHelper
  include QueryConcern
  include ListConcern

  include HourglassUi::Overview
  include HourglassUi::TimeLogs
  include HourglassUi::TimeBookings
  include HourglassUi::TimeTrackers

  def context_menu
    list_type = get_list_type
    @records = Hourglass.const_get(list_type.classify).find params[:ids]
    render "hourglass_ui/#{list_type}/context_menu", layout: false
  end

  def api_docs
  end

  private
  def authorize_foreign
    super { render_403 }
  end

  def get_list_type
    list_type = %w(time_bookings time_logs time_trackers).select {|val| val == params[:list_type]}.first
    render_403 unless list_type
    list_type
  end
end
