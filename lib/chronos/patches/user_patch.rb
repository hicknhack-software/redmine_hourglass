require_dependency 'user'
require_dependency 'project'
require_dependency 'principal'

module Chronos::Patches
  module UserPatch
    extend ActiveSupport::Concern

    included do
      class_eval do
        has_many :chronos_time_logs, class_name: 'Chronos::TimeLog'
        has_many :chronos_time_bookings, :through => :chronos_time_logs, class_name: 'Chronos::TimeBooking', source: :time_bookings
      end
    end

    def remove_references_before_destroy
      super
      substitute = ::User.anonymous
      Chronos::TimeLog.update_all ['user_id = ?', substitute.id], ['user_id = ?', id]
    end
  end
end

User.send :include, Chronos::Patches::UserPatch
