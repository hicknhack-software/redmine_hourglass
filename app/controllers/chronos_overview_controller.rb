class ChronosOverviewController < ChronosUiBaseController
  def index
    @time_tracker = User.current.chronos_time_tracker || Chronos::TimeTracker.new
  end
end
