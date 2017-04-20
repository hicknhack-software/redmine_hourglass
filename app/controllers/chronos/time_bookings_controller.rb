module Chronos
  class TimeBookingsController < ApiBaseController
    accept_api_auth :index, :show, :update, :destroy

    before_action :get_time_booking, only: [:show, :update, :destroy]
    before_action :authorize_global, only: [:index]
    before_action :find_project, :authorize, only: [:show, :update, :destroy]
    before_action :authorize_foreign, only: [:show, :update, :destroy]

    def index
      time_bookings = allowed_to?('index_foreign') ? Chronos::TimeBooking.all : User.current.chronos_time_bookings
      respond_with_success time_bookings
    end

    def show
      respond_with_success @time_booking
    end

    def update
      if @time_booking.update time_entry_attributes: time_booking_params
        respond_with_success
      else
        respond_with_error :bad_request, @time_booking.errors.full_messages
      end
    end

    def bulk_update
      bulk do |id, params|
        time_booking = Chronos::TimeBooking.find_by(id: id) or next
        time_booking.update time_entry_attributes: params.permit(:comments, :project_id, :issue_id, :activity_id)
        time_booking
      end
    end

    def destroy
      @time_booking.destroy
      respond_with_success
    end

    def bulk_destroy
      bulk do |id|
        time_booking = Chronos::TimeBooking.find_by(id: id) or next
        time_booking.destroy
      end
    end

    private
    def time_booking_params
      params.require(:time_booking).permit(:comments, :project_id, :issue_id, :activity_id)
    end

    def get_time_booking
      @time_booking = time_booking_from_id
      render_404 unless @time_booking.present?
      @request_resource = @time_booking
    end

    def time_booking_from_id
      Chronos::TimeBooking.find_by id: params[:id]
    end

    def find_project
      if action_name == 'update'
        find_project_from_params time_booking_params
      else
        super
      end
    end
  end
end
