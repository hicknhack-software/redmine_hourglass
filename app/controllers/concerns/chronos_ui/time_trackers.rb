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
  end
end
