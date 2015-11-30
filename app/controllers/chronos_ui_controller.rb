class ChronosUiController < ApplicationController
  helper Chronos::ApplicationHelper

  def index
    @time_tracker = User.current.chronos_time_tracker || Chronos::TimeTracker.new
  end

  def time_logs
  end

  def time_bookings
  end
end
