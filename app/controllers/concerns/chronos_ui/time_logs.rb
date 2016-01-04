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
    end

    def edit_time_logs
      time_log = get_time_log
      authorize_foreign
      render 'chronos_ui/time_logs/edit', locals: {time_log: time_log}, layout: false unless performed?
    end

    def book_time_logs
      time_log = get_time_log
      authorize_foreign
      render 'chronos_ui/time_logs/book', locals: {time_log: time_log, time_booking: time_log.build_time_booking}, layout: false unless performed?
    end

    private
    def get_time_log
      time_log = Chronos::TimeLog.find_by id: params[:id]
      render_404 unless time_log.present?
      @request_resource = time_log
    end
  end
end
