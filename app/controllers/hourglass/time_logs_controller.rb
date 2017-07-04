module Hourglass
  class TimeLogsController < ApiBaseController
    accept_api_auth :index, :show, :update, :create, :bulk_create, :bulk_update, :split, :join, :book, :bulk_book, :destroy, :bulk_destroy

    # removed to have consistency with other api controller
    # rescue_from Query::StatementInvalid, :with => :query_statement_invalid
    # def index
    #   params.merge! user_id: 'me' unless allowed_to?('index_foreign')
    #   @query = Hourglass::TimeLogQuery.build_from_params params, name: '_'
    #   scope = @query.results_scope
    #   offset, limit = api_offset_and_limit
    #   respond_with_success(
    #       count: scope.count,
    #       offset: offset,
    #       limit: limit,
    #       time_logs: scope.offset(offset).limit(limit).to_a
    #   )
    # end

    def index
      authorize Hourglass::TimeLog
      respond_with_success policy_scope(Hourglass::TimeLog)
    end

    def show
      respond_with_success authorize time_log_from_id
    end

    def create
      time_log = authorize TimeLog.new create_time_log_params
      if time_log.save
        respond_with_success time_log: time_log
      else
        respond_with_error :bad_request, time_log.errors.full_messages, array_mode: :sentence
      end
    end

    def bulk_create
      authorize Hourglass::TimeLog
      bulk do |_, params|
        time_log = authorize TimeLog.new create_time_log_params params
        time_log.save
        time_log
      end
    end

    def update
      time_log = authorize_update time_log_from_id, time_log_params
      if time_log.errors.empty?
        respond_with_success
      else
        respond_with_error :bad_request, time_log.errors.full_messages, array_mode: :sentence
      end
    end

    def bulk_update
      authorize Hourglass::TimeLog
      bulk do |id, params|
        authorize_update time_log_from_id(id), time_log_params(params)
      end
    end

    def split
      time_log = authorize time_log_from_id
      new_time_log = time_log.split split_params
      if new_time_log
        respond_with_success time_log: time_log, new_time_log: new_time_log
      else
        respond_with_error :bad_request, t('hourglass.api.time_logs.errors.split_failed')
      end
    end

    def join
      authorize Hourglass::TimeLog
      time_logs = Hourglass::TimeLog.find(id: params[:ids].uniq).order start: :asc
      time_log = time_logs.transaction do
        time_logs.reduce do |joined, tl|
          authorize tl
          raise ActiveRecord::Rollback unless joined.join_with tl
          joined
        end
      end
      if time_log && time_log.persisted?
        respond_with_success time_log
      else
        respond_with_error :bad_request, t('hourglass.api.time_logs.errors.join_failed')
      end
    end

    def book
      time_log = time_log_from_id
      time_booking = time_log.transaction do
        time_booking = time_log.book time_booking_params
        authorize time_log, :booking_allowed?
        time_booking
      end
      if time_booking.persisted?
        respond_with_success time_booking
      else
        respond_with_error :bad_request, time_booking.errors.full_messages, array_mode: :sentence
      end
    end

    def bulk_book
      authorize Hourglass::TimeLog
      bulk :time_bookings do |id, booking_params|
        time_log = authorize time_log_from_id id
        time_log.transaction do
          time_booking = time_log.book time_booking_params booking_params
          authorize time_log, :booking_allowed?
          time_booking
        end
      end
    end

    def destroy
      authorize(time_log_from_id).destroy
      respond_with_success
    end

    def bulk_destroy
      authorize Hourglass::TimeLog
      bulk do |id|
        authorize (time_log_from_id id).destroy
      end
    end

    private
    def time_log_params(params_hash = params.require(:time_log))
      parse_boolean :round, params_hash.permit(:start, :stop, :comments, :round, :user_id)
    end

    def create_time_log_params(params_hash = params.require(:time_log))
      params_hash.permit(:start, :stop, :comments, :user_id)
    end

    def split_params
      parse_boolean [:round, :insert_new_before]
      {
          split_at: Time.parse(params[:split_at]),
          insert_new_before: params[:insert_new_before],
          round: params[:round]
      }
    end

    def time_booking_params(params_hash = params.require(:time_booking))
      parse_boolean :round, params_hash.permit(:comments, :project_id, :issue_id, :activity_id, :round)
    end

    def time_log_from_id(id = params[:id])
      policy_scope(Hourglass::TimeLog).find id
    end
  end
end
