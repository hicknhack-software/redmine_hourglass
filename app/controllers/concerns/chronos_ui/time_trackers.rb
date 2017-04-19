module ChronosUi
  module TimeTrackers
    extend ActiveSupport::Concern

    included do
      menu_item :chronos_time_trackers, only: :time_trackers
    end

    def time_trackers
      retrieve_query
      init_sort
      @list_arguments = list_arguments
      render 'chronos_ui/query_view'
    end

    def edit_time_trackers
      time_tracker = get_time_tracker
      authorize_foreign
      render 'chronos_ui/time_trackers/edit', locals: {time_trackers: [time_tracker]}, layout: false unless performed?
    end

    def bulk_edit_time_trackers
      time_trackers = params[:ids].map do |id|
        @request_resource = Chronos::TimeTracker.find_by id: id
        next unless @request_resource
        authorize_foreign { next }
        @request_resource
      end.compact
      render_404 if time_trackers.empty?
      render 'chronos_ui/time_trackers/edit', locals: {time_trackers: time_trackers}, layout: false unless performed?
    end

    private
    def get_time_tracker
      time_tracker = Chronos::TimeTracker.find_by id: params[:id]
      render_404 unless time_tracker.present?
      @request_resource = time_tracker
    end
  end
end
