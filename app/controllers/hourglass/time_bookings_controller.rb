module Hourglass
  class TimeBookingsController < ApiBaseController
    accept_api_auth :index, :show, :create, :bulk_create, :update, :bulk_update, :destroy, :bulk_destroy

    def index
      list_records Hourglass::TimeBooking
    end

    def show
      respond_with_success authorize time_booking_from_id
    end

    def create
      time_log, time_booking = nil
      ActiveRecord::Base.transaction do
        time_log = Hourglass::TimeLog.create create_time_log_params
        raise ActiveRecord::Rollback unless time_log.persisted?
        time_booking = authorize time_log.book time_entry_params
        raise ActiveRecord::Rollback unless time_booking.persisted?
        respond_with_success time_log: time_log, time_booking: time_booking
      end
      error_messages = time_log.errors.full_messages
      error_messages += time_booking.errors.full_messages if time_booking
      respond_with_error :bad_request, error_messages, array_mode: :sentence
    end

    def bulk_create
      bulk do |_, params|
        result = nil
        ActiveRecord::Base.transaction do
          result = Hourglass::TimeLog.create create_time_log_params params
          raise ActiveRecord::Rollback unless result.persisted?
          result = authorize result.book time_entry_params(params).except(:user_id)
          raise ActiveRecord::Rollback unless result.persisted?
          result.include_time_log!
        end
        result
      end
    end

    def update
      attributes = {time_entry_attributes: time_entry_params}
      attributes[:time_log_attributes] = attributes[:time_entry_attributes].slice(:user_id) if attributes[:time_entry_attributes][:user_id]
      do_update time_booking_from_id, attributes
    end

    def bulk_update
      authorize Hourglass::TimeBooking
      bulk do |id, params|
        attributes = {time_entry_attributes: time_entry_params(params)}
        attributes[:time_log_attributes] = attributes[:time_entry_attributes].slice(:user_id) if attributes[:time_entry_attributes][:user_id]
        authorize_update time_booking_from_id(id), attributes
      end
    end

    def destroy
      authorize(time_booking_from_id).destroy
      respond_with_success
    end

    def bulk_destroy
      authorize Hourglass::TimeBooking
      bulk do |id|
        authorize(time_booking_from_id id).destroy
      end
    end

    private
    def create_time_log_params(params_hash = params.require(:time_booking))
      params_hash.permit(:start, :stop, :comments, :user_id)
    end

    def time_entry_params(params_hash = params.require(:time_booking))
      params_hash.permit(:comments, :project_id, :issue_id, :activity_id, :user_id,
                         custom_field_values: custom_field_keys(params_hash))
    end

    def time_booking_from_id(id = params[:id])
      Hourglass::TimeBooking.find id
    end
  end
end
