module Chronos
  class TimeBookingsController < ApiBaseController
    accept_api_auth :index, :show, :update, :destroy
    before_action :get_time_booking, only: [:show, :update, :destroy]

    def index
      respond_with_success Chronos::TimeBooking.all
    end

    def show
      respond_with_success @time_booking
    end

    def update
      if @time_booking.update time_booking_params
        respond_with_success
      else
        respond_with_error :bad_request, @time_booking.errors.full_messages
      end
    end

    def destroy
      @time_booking.destroy
      respond_with_success
    end

    private
    def time_booking_params
      params.require(:time_booking).permit(:start, :stop, time_entry_arguments: [:comments, :project_id, :issue_id, :activity_id])
    end

    def get_time_booking
      @time_booking = time_booking_from_id
      respond_with_error :not_found, I18n.t('chronos.api.time_booking.errors.not_found') unless @time_booking.present?
    end

    def time_booking_from_id
      Chronos::TimeBooking.find_by id: params[:id]
    end
  end
end
