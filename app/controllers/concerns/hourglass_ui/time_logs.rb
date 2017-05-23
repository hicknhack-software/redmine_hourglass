module HourglassUi
  module TimeLogs
    extend ActiveSupport::Concern

    included do
      menu_item :hourglass_time_logs, only: :time_logs
    end

    def time_logs
      retrieve_query
      init_sort
      @list_arguments = list_arguments
    end

    def new_time_logs
      now = Time.now.change(sec: 0)
      time_log = Hourglass::TimeLog.new start: now, stop: now + Hourglass::DateTimeCalculations.round_minimum
      render 'hourglass_ui/time_logs/new', locals: {time_log: time_log}, layout: false
    end

    def edit_time_logs
      time_log = get_time_log
      authorize_foreign
      render 'hourglass_ui/time_logs/edit', locals: {time_logs: [time_log]}, layout: false unless performed?
    end

    def bulk_edit_time_logs
      time_logs = params[:ids].map do |id|
        time_log = Hourglass::TimeLog.find_by id: id
        next unless time_log && foreign_allowed_to?(time_log)
        time_log
      end.compact
      render_404 if time_logs.empty?
      render 'hourglass_ui/time_logs/edit', locals: {time_logs: time_logs}, layout: false unless performed?
    end

    def book_time_logs
      time_log = get_time_log
      render_error t('hourglass.api.time_logs.errors.already_booked') if time_log.booked?
      authorize_foreign
      render 'hourglass_ui/time_logs/book', locals: {time_logs: [time_log]}, layout: false unless performed?
    end

    def bulk_book_time_logs
      time_logs = params[:ids].map do |id|
        time_log = Hourglass::TimeLog.find_by id: id
        next unless time_log && !time_log.booked? && foreign_allowed_to?(time_log)
        time_log
      end.compact
      render_404 if time_logs.empty?
      render 'hourglass_ui/time_logs/book', locals: {time_logs: time_logs}, layout: false unless performed?
    end

    private
    def get_time_log
      time_log = Hourglass::TimeLog.find_by id: params[:id]
      render_404 unless time_log.present?
      @request_resource = time_log
    end
  end
end
