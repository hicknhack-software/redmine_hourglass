require_dependency 'project'
module RedminePatches
  module ProjectPatch
    extend ActiveSupport::Concern

    included do
      class_eval do
        has_many :chronos_time_bookings, dependent: :delete_all, class_name: 'Chronos::TimeBooking'
      end
    end
  end
end

Project.send :include, RedminePatches::ProjectPatch
