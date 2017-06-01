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

  include AuthorizationConcern
  include SortHelper
  include QueryConcern
  include ListConcern

  include HourglassUi::Overview
  include HourglassUi::TimeLogs
  include HourglassUi::TimeBookings
  include HourglassUi::TimeTrackers

  def context_menu
    @records = Hourglass.const_get(params[:list_type].classify).find params[:ids]
    render "hourglass_ui/#{params[:list_type]}/context_menu", layout: false
  end

  def api_docs
    @swagger_endpoints = [{path: "/#{Hourglass::NAMESPACE}/api-docs/v1/swagger.json", title: 'API V1'}]
  end

  private
  def authorize_foreign
    super { render_403 }
  end
end
