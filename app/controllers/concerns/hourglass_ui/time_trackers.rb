module HourglassUi
  module TimeTrackers
    extend ActiveSupport::Concern

    included do
      menu_item :hourglass_time_trackers, only: :time_trackers
      before_action(only: :time_trackers) { authorize Hourglass::TimeTracker, :view? }
      before_action(only: :new_time_trackers) { authorize Hourglass::TimeTracker, :create? }
      before_action(only: [:edit_time_trackers, :bulk_edit_time_trackers]) { authorize Hourglass::TimeTracker, :change? }
    end

    def time_trackers
      retrieve_query
      init_sort
      @list_arguments = list_arguments
      render 'hourglass_ui/query_view'
    end

    def edit_time_trackers
      time_tracker = get_time_tracker
      authorize_foreign
      render 'hourglass_ui/time_trackers/edit', locals: {time_trackers: [time_tracker]}, layout: false unless performed?
    end

    def bulk_edit_time_trackers
      time_trackers = params[:ids].map do |id|
        @request_resource = Hourglass::TimeTracker.find_by id: id
        next unless @request_resource && foreign_allowed_to?
        @request_resource
      end.compact
      render_404 if time_trackers.empty?
      render 'hourglass_ui/time_trackers/edit', locals: {time_trackers: time_trackers}, layout: false unless performed?
    end

    private
    def get_time_tracker
      time_tracker = Hourglass::TimeTracker.find_by id: params[:id]
      render_404 unless time_tracker.present?
      @request_resource = time_tracker
    end
  end
end
