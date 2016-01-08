module Chronos
  class TimeLogsController < ApiBaseController
    accept_api_auth :index, :show, :update, :split, :combine, :book, :destroy

    before_action :get_time_log, only: [:show, :update, :split, :combine, :book, :destroy]
    before_action :authorize_global, only: [:index, :show, :update, :split, :combine, :destroy]
    before_action :find_optional_project, :authorize_with_project_or_global, only: [:book]
    before_action :authorize_foreign, only: [:show, :update, :split, :combine, :book, :destroy]
    before_action :authorize_update_time, only: [:update]
    before_action :authorize_update_booking, only: [:split]

    rescue_from Query::StatementInvalid, :with => :query_statement_invalid

    def index
      params.merge! user_id: 'me' unless allowed_to?('index_foreign')
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
      new_time_log = @time_log.split split_params
      if new_time_log
        respond_with_success time_log: @time_log, new_time_log: new_time_log
      else
        respond_with_error :bad_request, t('chronos.api.time_logs.errors.split_failed')
      end
    end

    def combine
      time_log2 = Chronos::TimeLog.find_by id: params[:other]
      render_404 message: t('chronos.api.time_logs.errors.other_not_found') unless time_log2.present?
      if @time_log.combine_with time_log2
        respond_with_success @time_log
      else
        respond_with_error :bad_request, t('chronos.api.time_logs.errors.combine_failed')
      end
    end

    def book
      time_booking = @time_log.book time_booking_params
      if time_booking.persisted?
        respond_with_success time_booking
      else
        respond_with_error :bad_request, time_booking.errors.full_messages
      end
    rescue Chronos::AlreadyBookedException
      respond_with_error :bad_request, t('chronos.api.time_logs.errors.already_booked')
    end

    def destroy
      @time_log.destroy
      respond_with_success
    end

    private
    def time_log_params
      parse_boolean :round, params.require(:time_log).permit(:start, :stop, :comments, :round)
    end

    def split_params
      parse_boolean [:round, :insert_new_before]
      {
          split_at: Time.parse(params[:split_at]),
          insert_new_before: params[:insert_new_before],
          round: params[:round]
      }
    end

    def time_booking_params
      parse_boolean :round, params.require(:time_booking).permit(:comments, :project_id, :issue_id, :activity_id, :round)
    end

    def get_time_log
      @time_log = time_log_from_id
      render_404 unless @time_log.present?
      @request_resource = @time_log
    end

    def time_log_from_id
      Chronos::TimeLog.find_by id: params[:id]
    end

    def find_optional_project
      @project = Project.find_by(id: params[:time_booking].presence[:project_id])
      render_404 message: t('chronos.api.time_logs.errors.booking_project_not_found') unless @project.present?
    end

    def authorize_update_booking
      if @time_log.booked? && !allowed_to?('update_time', 'chronos/time_bookings')
        render_403 message: t('chronos.api.time_bookings.errors.update_time_forbidden')
      end
    end
  end
end
