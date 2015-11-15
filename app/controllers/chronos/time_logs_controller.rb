module Chronos
  class TimeLogsController < ApiBaseController
    accept_api_auth :index, :show, :update, :book, :destroy
    before_action :get_time_log, only: [:show, :update, :book, :destroy]
    before_action :sanitize_booking_time_params, only: :book

    def index
      respond_with_success Chronos::TimeLog.all
    end

    def show
      respond_with_success @time_log
    end

    def update
      if @time_log.update time_log_params
        respond_with_success
      else
        respond_with_error :bad_request, @time_log.errors.full_messages
      end
    end

    def book
      time_booking = @time_log.book booking_params
      if time_booking.persisted?
        respond_with_success time_booking
      else
        respond_with_error :bad_request, time_booking.errors.full_messages
      end
    rescue Chronos::DateTimeCalculations::InvalidIntervalsException
      respond_with_error :bad_request, I18n.t('chronos.api.time_log.errors.invalid_interval')
    rescue Chronos::DateTimeCalculations::NoFittingPossibleException
      respond_with_error :bad_request, I18n.t('chronos.api.time_log.errors.no_fitting')
    rescue Chronos::DateTimeCalculations::RecordInsideIntervalException
      respond_with_error :bad_request, I18n.t('chronos.api.time_log.errors.record_inside_interval')
    end

    def destroy
      @time_log.destroy
      if @time_log.destroyed?
        respond_with_success
      else
        respond_with_error :internal_server_error, I18n.t('chronos.api.time_log.errors.destroy_failed')
      end
    end

    private
    def time_log_params
      params.require(:time_log).permit(:start, :stop, :comments)
    end

    def booking_params
      params.require(:booking).permit(:start, :stop, :comments, :project_id, :issue_id, :activity_id, :round)
    end

    def get_time_log
      @time_log = time_log_from_id
      respond_with_error :not_found, I18n.t('chronos.api.time_log.errors.not_found') unless @time_log.present?
    end

    def time_log_from_id
      Chronos::TimeLog.find_by id: params[:id]
    end

    def sanitize_booking_time_params
      [:start, :stop].each do |time_param|
        if params[:booking][time_param].present?
          params[:booking][time_param] = Time.zone.parse params[:booking][time_param]
        end
      end
    end
  end
end