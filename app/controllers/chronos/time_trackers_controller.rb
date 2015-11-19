module Chronos
  class TimeTrackersController < ApiBaseController
    accept_api_auth :index, :show, :start, :update, :stop
    before_action :get_time_tracker, only: [:show, :update, :stop]

    def index
      respond_with_success Chronos::TimeTracker.all
    end

    def show
      respond_with_success @time_tracker
    end

    def start
      time_tracker = Chronos::TimeTracker.start
      if time_tracker.persisted?
        respond_with_success time_tracker
      else
        respond_with_error :bad_request, time_tracker.errors.full_messages
      end
    end

    def update
      if @time_tracker.update time_tracker_params
        respond_with_success
      else
        respond_with_error :bad_request, @time_tracker.errors.full_messages
      end
    end

    def stop
      time_log = @time_tracker.stop
      time_booking = time_log.time_booking
      if time_log.persisted?
        respond_with_success time_log: time_log, time_booking: time_booking
      else
        respond_with_error :bad_request, time_log.errors.full_messages
      end
    end

    private
    def time_tracker_params
      params.require(:time_tracker).permit(:start, :comments, :round, :project_id, :issue_id, :activity_id)
    end

    def get_time_tracker
      @time_tracker = params[:id] == 'current' ? current_time_tracker : time_tracker_from_id
      respond_with_error :not_found, I18n.t('chronos.api.time_tracker.errors.not_found') unless @time_tracker.present?
    end

    def current_time_tracker
      User.current.chronos_time_tracker
    end

    def time_tracker_from_id
      Chronos::TimeTracker.find_by id: params[:id]
    end
  end
end
