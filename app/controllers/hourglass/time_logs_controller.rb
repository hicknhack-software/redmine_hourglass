module Hourglass
  class TimeLogsController < ApiBaseController
    accept_api_auth :index, :show, :update, :bulk_update, :split, :combine, :book, :bulk_book, :destroy, :bulk_destroy

    before_action :get_time_log, only: [:show, :update, :split, :combine, :book, :destroy]
    before_action :authorize_global, only: [:index, :show, :update, :bulk_update, :split, :combine, :destroy, :bulk_destroy]
    before_action :find_project, :authorize_book, only: [:book]
    before_action :authorize_foreign, only: [:show, :update, :split, :combine, :book, :destroy]
    before_action :authorize_update_time, only: [:update]
    before_action :authorize_update_booking, only: [:split]

    rescue_from Query::StatementInvalid, :with => :query_statement_invalid

    def index
      params.merge! user_id: 'me' unless allowed_to?('index_foreign')
      @query = Hourglass::TimeLogQuery.build_from_params params, name: '_'
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
        respond_with_error :bad_request, @time_log.errors.full_messages, array_mode: :sentence
      end
    end

    def bulk_update
      bulk do |id, params|
        @request_resource = Hourglass::TimeLog.find_by(id: id) or next
        next foreign_forbidden_message unless foreign_allowed_to?
        next update_time_forbidden_message unless update_time_allowed?
        @request_resource.update parse_boolean :round, params.permit(:start, :stop, :comments, :round)
        @request_resource
      end
    end

    def split
      new_time_log = @time_log.split split_params
      if new_time_log
        respond_with_success time_log: @time_log, new_time_log: new_time_log
      else
        respond_with_error :bad_request, t('hourglass.api.time_logs.errors.split_failed')
      end
    end

    def combine
      time_log2 = Hourglass::TimeLog.find_by id: params[:other]
      render_404 message: t('hourglass.api.time_logs.errors.other_not_found') unless time_log2.present?
      if @time_log.combine_with time_log2
        respond_with_success @time_log
      else
        respond_with_error :bad_request, t('hourglass.api.time_logs.errors.combine_failed')
      end
    end

    def book
      respond_with_error :bad_request, t('hourglass.api.time_logs.errors.already_booked') if @time_log.booked?
      time_booking = @time_log.book time_booking_params
      if time_booking.persisted?
        respond_with_success time_booking
      else
        respond_with_error :bad_request, time_booking.errors.full_messages, array_mode: :sentence
      end
    end

    def bulk_book
      bulk :time_bookings do |id, booking_params|
        @request_resource = Hourglass::TimeLog.find_by(id: id) or next
        error_msg = find_project booking_params, mode: :inline
        next error_msg if error_msg.is_a? String
        next booking_forbidden_message unless book_allowed?
        next foreign_forbidden_message unless foreign_allowed_to?
        next t('hourglass.api.time_logs.errors.already_booked') if @request_resource.booked?
        @request_resource.book parse_boolean :round, booking_params.permit(:comments, :project_id, :issue_id, :activity_id, :round)
      end
    end

    def destroy
      @time_log.destroy
      respond_with_success
    end

    def bulk_destroy
      bulk do |id|
        @request_resource = Hourglass::TimeLog.find_by(id: id) or next
        next foreign_forbidden_message unless foreign_allowed_to?
        @request_resource.destroy
      end
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
      Hourglass::TimeLog.find_by id: params[:id]
    end

    def authorize_update_booking
      if @time_log.booked? && !allowed_to?('update_time', 'hourglass/time_bookings')
        render_403 message: t('hourglass.api.time_bookings.errors.update_time_forbidden')
      end
    end

    def find_project(booking_params = nil, **opts)
      find_project_from_params (booking_params || time_booking_params).with_indifferent_access, opts
    end
  end
end
