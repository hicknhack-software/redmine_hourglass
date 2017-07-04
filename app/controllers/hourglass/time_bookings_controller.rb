module Hourglass
  class TimeBookingsController < ApiBaseController
    accept_api_auth :index, :show, :create, :bulk_create, :update, :bulk_update, :destroy, :bulk_destroy

    before_action :get_time_booking, only: [:show, :update, :destroy]
    before_action :find_project, :authorize, only: [:show, :create, :update, :destroy]
    before_action :authorize_foreign, only: [:show, :update, :destroy]
    before_action :authorize_update_all, only: [:create]
    before_action :require_login, only: [:bulk_update, :bulk_create, :bulk_destroy]

    def index
      authorize Hourglass::TimeBooking, :view?
      time_bookings = allowed_to?('index_foreign') ? Hourglass::TimeBooking.visible : User.current.hourglass_time_bookings
      respond_with_success time_bookings
    end

    def show
      respond_with_success @time_booking
    end

    def create
      time_log, time_booking = nil
      ActiveRecord::Base.transaction do
        time_log = TimeLog.create create_time_log_params
        render_403 message: foreign_forbidden_message unless foreign_allowed_to? time_log
        raise ActiveRecord::Rollback unless time_log.persisted?
        time_booking = time_log.book time_booking_params
        render_403 message: foreign_forbidden_message unless foreign_allowed_to? time_booking
        raise ActiveRecord::Rollback unless time_booking.persisted?
        respond_with_success time_log: time_log, time_booking: time_booking
      end
      error_messages = time_log.errors.full_messages
      error_messages += time_booking.errors.full_messages if time_booking
      respond_with_error :bad_request, error_messages, array_mode: :sentence
    end

    def bulk_create
      bulk do |_, params|
        error_msg = find_project params, mode: :inline
        next error_msg if error_msg.is_a? String
        next t('hourglass.api.errors.forbidden') unless allowed_to?
        next update_all_forbidden_message unless update_all_allowed? params
        result = nil
        ActiveRecord::Base.transaction do
          result = time_log = TimeLog.create params.permit(:start, :stop, :comments, :user_id)
          raise ActiveRecord::Rollback unless time_log.persisted?
          result = time_booking = time_log.book params.permit(:comments, :project_id, :issue_id, :activity_id)
          raise ActiveRecord::Rollback unless time_booking.persisted?
          result = foreign_forbidden_message and raise ActiveRecord::Rollback unless foreign_allowed_to? time_booking
          time_booking.include_time_log!
        end
        result
      end
    end

    def update
      attributes = {time_entry_attributes: time_booking_params}
      attributes[:time_log_attributes] = time_booking_params.slice(:user_id) if time_booking_params[:user_id]
      if @time_booking.update attributes
        respond_with_success
      else
        respond_with_error :bad_request, @time_booking.errors.full_messages, array_mode: :sentence
      end
    end

    def bulk_update
      bulk do |id, params|
        time_booking = Hourglass::TimeBooking.find_by(id: id) or next
        error_msg = find_project params, resource: time_booking, mode: :inline
        next error_msg if error_msg.is_a? String
        next t('hourglass.api.errors.forbidden') unless allowed_to?
        next foreign_forbidden_message unless foreign_allowed_to? time_booking
        attributes = {time_entry_attributes: params.permit(:comments, :project_id, :issue_id, :activity_id)}
        attributes[:time_log_attributes] = params.permit(:user_id) if params[:user_id]
        time_booking.update attributes
        time_booking
      end
    end

    def destroy
      @time_booking.destroy
      respond_with_success
    end

    def bulk_destroy
      bulk do |id|
        time_booking = Hourglass::TimeBooking.find_by(id: id) or next
        find_project resource: time_booking
        next t('hourglass.api.errors.forbidden') unless allowed_to?
        next foreign_forbidden_message unless foreign_allowed_to? time_booking
        time_booking.destroy
      end
    end

    private
    def create_time_log_params
      params.require(:time_booking).permit(:start, :stop, :comments, :user_id)
    end

    def time_booking_params
      params.require(:time_booking).permit(:comments, :project_id, :issue_id, :activity_id, :user_id)
    end

    def get_time_booking
      @time_booking = time_booking_from_id
      render_404 unless @time_booking.present?
      @request_resource = @time_booking
    end

    def time_booking_from_id
      Hourglass::TimeBooking.find_by id: params[:id]
    end

    def find_project(params = nil, resource: @request_resource, **opts)
      if action_name.in? %w(create bulk_create update bulk_update)
        find_project_from_params((params || time_booking_params).with_indifferent_access, opts) || (resource && super(resource))
      else
        super resource
      end
    end
  end
end
