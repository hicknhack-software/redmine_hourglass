module Chronos
  module RedminePatches
    module TimeEntryPatch
      extend ActiveSupport::Concern

      included do
        class_eval do
          has_one :chronos_time_booking, dependent: :delete, class_name: 'Chronos::TimeBooking'
        end
      end
    end
  end
end