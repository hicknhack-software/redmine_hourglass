module HourglassUi
  module TimeTrackers
    extend ActiveSupport::Concern

    included do
      menu_item :hourglass_time_trackers, only: :time_trackers
    end

    def time_trackers
      list_records Hourglass::TimeTracker
      render 'hourglass_ui/query_view'
    end

    def edit_time_trackers
      record_form Hourglass::TimeTracker
    end

    def bulk_edit_time_trackers
      bulk_record_form Hourglass::TimeTracker
    end
  end
end
