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
    end

    def edit_time_trackers
      time_tracker = get_time_tracker
      authorize_foreign
      render 'chronos_ui/time_trackers/edit', locals: {time_tracker: time_tracker}, layout: false unless performed?
    end

    private
    def get_time_tracker
      time_tracker = Chronos::TimeTracker.find_by id: params[:id]
      render_404 unless time_tracker.present?
      @request_resource = time_tracker
    end
  end
end
