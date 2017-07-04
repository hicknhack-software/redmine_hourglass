module Hourglass
  class TimeTrackersController < ApiBaseController
    accept_api_auth :index, :show, :start, :update, :bulk_update, :stop, :destroy, :bulk_destroy

    def index
      authorize Hourglass::TimeTracker
      respond_with_success policy_scope(Hourglass::TimeTracker)
    end

    def show
      respond_with_success authorize get_time_tracker
    end

    def start
      time_tracker = authorize Hourglass::TimeTracker.new params[:time_tracker] ? time_tracker_params.except(:start) : {}
      if time_tracker.save
        respond_with_success time_tracker
      else
        respond_with_error :bad_request, time_tracker.errors.full_messages, array_mode: :sentence
      end
    end

    def update
      do_update get_time_tracker, time_tracker_params
    end

    def bulk_update
      authorize Hourglass::TimeTracker
      bulk do |id, params|
        authorize_update time_tracker_from_id(id), time_tracker_params(params)
      end
    end

    def stop
      time_tracker = authorize get_time_tracker
      time_log, time_booking = time_tracker.transaction do
        time_log = time_tracker.stop
        authorize time_log, :book? if time_tracker.project
        [time_log, time_log && time_log.time_booking]
      end
      if time_tracker.destroyed?
        respond_with_success({time_log: time_log, time_booking: time_booking}.compact)
      else
        error_messages = time_log.errors.full_messages
        error_messages += time_booking.errors.full_messages if time_booking
        respond_with_error :bad_request, error_messages, array_mode: :sentence
      end
    end

    def destroy
      authorize(get_time_tracker).destroy
      respond_with_success
    end

    def bulk_destroy
      authorize Hourglass::TimeTracker
      bulk do |id|
        authorize(time_tracker_from_id id).destroy
      end
    end

    private
    def time_tracker_params(params_hash = params.require(:time_tracker))
      params_hash.permit(:start, :comments, :round, :project_id, :issue_id, :activity_id, :user_id)
    end

    def get_time_tracker
      params[:id] == 'current' ? current_time_tracker : time_tracker_from_id
    end

    def current_time_tracker
      User.current.hourglass_time_tracker
    end

    def time_tracker_from_id(id = params[:id])
      policy_scope(Hourglass::TimeTracker).find id
    end
  end
end
