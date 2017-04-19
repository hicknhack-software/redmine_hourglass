module ChronosUi
  module TimeLogs
    extend ActiveSupport::Concern

    included do
      menu_item :chronos_time_logs, only: :time_logs
    end

    def time_logs
      retrieve_query
      init_sort
      @list_arguments = list_arguments
      render 'chronos_ui/query_view'
    end

    def edit_time_logs
      time_log = get_time_log
      authorize_foreign
      render 'chronos_ui/time_logs/edit', locals: {time_logs: [time_log]}, layout: false unless performed?
    end

    def bulk_edit_time_logs
      time_logs = params[:ids].map do |id|
        @request_resource = Chronos::TimeLog.find_by id: id
        next unless @request_resource
        authorize_foreign { next }
        @request_resource
      end.compact
      render_404 if time_logs.empty?
      render 'chronos_ui/time_logs/edit', locals: {time_logs: time_logs}, layout: false unless performed?
    end

    def book_time_logs
      time_log = get_time_log
      render_error t('chronos.api.time_logs.errors.already_booked') if time_log.booked?
      authorize_foreign
      render 'chronos_ui/time_logs/book', locals: {time_logs: [time_log]}, layout: false unless performed?
    end

    def bulk_book_time_logs
      time_logs = params[:ids].map do |id|
        @request_resource = Chronos::TimeLog.find_by id: id
        next unless @request_resource && !@request_resource.booked?
        authorize_foreign { next }
        @request_resource
      end.compact
      render_404 if time_logs.empty?
      render 'chronos_ui/time_logs/book', locals: {time_logs: time_logs}, layout: false unless performed?
    end

    private
    def get_time_log
      time_log = Chronos::TimeLog.find_by id: params[:id]
      render_404 unless time_log.present?
      @request_resource = time_log
    end
  end
end
