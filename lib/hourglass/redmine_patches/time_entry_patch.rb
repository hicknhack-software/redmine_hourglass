module Hourglass
  module RedminePatches
    module TimeEntryPatch
      extend ActiveSupport::Concern

      included do
        has_one :hourglass_time_booking, dependent: :delete, class_name: 'Hourglass::TimeBooking'
      end
    end
  end
end
