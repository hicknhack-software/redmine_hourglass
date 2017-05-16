module Hourglass
  class TimeBookingsController < ApiBaseController
    accept_api_auth :index, :show, :update, :bulk_update, :destroy, :bulk_destroy

    before_action :get_time_booking, only: [:show, :update, :destroy]
    before_action :authorize_global, only: [:index]
    before_action :find_project, :authorize, only: [:show, :update, :destroy]
    before_action :authorize_foreign, only: [:show, :update, :destroy]

    def index
      time_bookings = allowed_to?('index_foreign') ? Hourglass::TimeBooking.all : User.current.hourglass_time_bookings
      respond_with_success time_bookings
    end

    def show
      respond_with_success @time_booking
    end

    def update
      if @time_booking.update time_entry_attributes: time_booking_params
        respond_with_success
      else
        respond_with_error :bad_request, @time_booking.errors.full_messages, array_mode: :sentence
      end
    end

    def bulk_update
      bulk do |id, booking_params|
        @request_resource = Hourglass::TimeBooking.find_by(id: id) or next
        error_msg = find_project booking_params, mode: :inline
        next error_msg if error_msg.is_a? String
        next t('hourglass.api.errors.forbidden') unless allowed_to?
        next foreign_forbidden_message unless foreign_allowed_to?
        @request_resource.update time_entry_attributes: booking_params.permit(:comments, :project_id, :issue_id, :activity_id)
        @request_resource
      end
    end

    def destroy
      @time_booking.destroy
      respond_with_success
    end

    def bulk_destroy
      bulk do |id|
        @request_resource = Hourglass::TimeBooking.find_by(id: id) or next
        find_project
        next t('hourglass.api.errors.forbidden') unless allowed_to?
        next foreign_forbidden_message unless foreign_allowed_to?
        @request_resource.destroy
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
      Hourglass::TimeBooking.find_by id: params[:id]
    end

    def find_project(booking_params = nil, **opts)
      if action_name == 'update'
        find_project_from_params (booking_params || time_booking_params).with_indifferent_access, opts
      else
        super()
      end
    end
  end
end
