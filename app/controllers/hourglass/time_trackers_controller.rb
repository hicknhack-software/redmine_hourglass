module Hourglass
  class TimeTrackersController < ApiBaseController
    accept_api_auth :index, :show, :start, :update, :bulk_update, :stop, :destroy, :bulk_destroy

    def index
      list_records Hourglass::TimeTracker
    end

    def show
      respond_with_success authorize get_time_tracker
    end

    def start
      process_current_action
      time_tracker = authorize Hourglass::TimeTracker.new time_tracker_params? ? time_tracker_params.except(:start) : {}
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
        authorize_update time_tracker_from_id(id), time_tracker_permit(params)
      end
    end

    def stop
      time_tracker = authorize get_time_tracker
      time_tracker.assign_attributes time_tracker_params if time_tracker_params?
      time_log, time_booking = stop_time_tracker(time_tracker)
      if time_tracker.destroyed?
        respond_with_success({time_log: time_log, time_booking: time_booking}.compact)
      else
        error_messages = time_log&.errors&.full_messages || []
        error_messages += time_booking&.errors&.full_messages || []
        error_messages = [t('hourglass.api.errors.internal_server_error')] if error_messages.empty?
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
    def time_tracker_params?
      params[:time_tracker].present?
    end
    def time_tracker_params
      time_tracker_permit params.require(:time_tracker)
    end
    def current_action_param
      params[:current_action]
    end
    def current_update_params?
      params[:current_update].present?
    end
    def current_update_params
      time_tracker_permit params.require(:current_update)
    end
    def time_tracker_permit(hash)
      hash.permit(:start, :comments, :round, :project_id, :issue_id, :activity_id, :user_id,
                   custom_field_values: custom_field_keys(hash))
    end

    def get_time_tracker(id = params[:id])
      id == 'current' ? current_time_tracker : time_tracker_from_id(id)
    end

    def current_time_tracker
      User.current.hourglass_time_tracker or raise ActiveRecord::RecordNotFound
    end

    def time_tracker_from_id(id)
      Hourglass::TimeTracker.find id
    end

    def stop_time_tracker(time_tracker)
      time_tracker.transaction do
        time_log = time_tracker.stop
        authorize time_log, :booking_allowed? if time_log && time_tracker.project
        [time_log, time_log&.time_booking]
      end if time_tracker.valid?
    end

    def process_current_action
      case current_action_param
      when 'destroy'
        authorize(get_time_tracker).destroy
        true
      when 'stop'
        time_tracker = authorize get_time_tracker
        time_tracker.assign_attributes current_update_params if current_update_params?
        time_log, time_booking = stop_time_tracker(time_tracker)
        if time_tracker.destroyed?
          true
        else
          error_messages = time_log&.errors&.full_messages || []
          error_messages += time_booking&.errors&.full_messages || []
          respond_with_error :bad_request, error_messages, array_mode: :sentence
          false
        end
      else
        true
      end
    end
  end
end
