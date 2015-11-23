module Chronos
  class TimeLogsController < ApiBaseController
    accept_api_auth :index, :show, :update, :split, :combine, :book, :destroy
    before_action :get_time_log, only: [:show, :update, :split, :combine, :book, :destroy]
    before_action :sanitize_booking_time_params, only: :book

    rescue_from Query::StatementInvalid, :with => :query_statement_invalid

    def index
      @query = Chronos::TimeLogQuery.build_from_params params, name: '_'
      scope = @query.results_scope
      offset, limit = api_offset_and_limit
      respond_with_success(
          count: scope.count,
          offset: offset,
          limit: limit,
          time_logs: scope.offset(offset).limit(limit).to_a
      )
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

    def split
      new_time_log = @time_log.split Time.zone.parse params[:split_at]
      if new_time_log
        respond_with_success time_log: @time_log, new_time_log: new_time_log
      else
        respond_with_error :bad_request, I18n.t('chronos.api.time_log.errors.split_failed')
      end
    end

    def combine
      time_log2 = Chronos::TimeLog.find_by id: params[:other]
      respond_with_error :not_found, I18n.t('chronos.api.time_log.errors.other_not_found') unless time_log2.present?
      if @time_log.combine_with time_log2
        respond_with_success @time_log
      else
        respond_with_error :bad_request, I18n.t('chronos.api.time_log.errors.combine_failed')
      end
    end

    def book
      time_booking = @time_log.book booking_params
      if time_booking.persisted?
        respond_with_success time_booking
      else
        respond_with_error :bad_request, time_booking.errors.full_messages
      end
    end

    def destroy
      @time_log.destroy
      respond_with_success
    end

    private
    def time_log_params
      params.require(:time_log).permit(:start, :stop, :comments, :round)
    end

    def booking_params
      params.require(:booking).permit(:comments, :project_id, :issue_id, :activity_id, :round)
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
