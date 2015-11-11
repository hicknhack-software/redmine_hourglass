require_dependency 'user'
require_dependency 'project'
require_dependency 'principal'
module Chronos
  module RedminePatches
    module UserPatch
      extend ActiveSupport::Concern

      included do
        class_eval do
          has_many :chronos_time_logs, class_name: 'Chronos::TimeLog'
          has_many :chronos_time_bookings, :through => :chronos_time_logs, class_name: 'Chronos::TimeBooking', source: :time_bookings
          has_one :chronos_time_tracker, class_name: 'Chronos::TimeTracker'
        end
      end

      def remove_references_before_destroy
        super
        substitute = ::User.anonymous
        Chronos::TimeLog.update_all ['user_id = ?', substitute.id], ['user_id = ?', id]
        Chronos::TimeTracker.update_all ['user_id = ?', substitute.id], ['user_id = ?', id]
      end
    end
  end
end

ActionDispatch::Callbacks.to_prepare do
  User.send :include, Chronos::RedminePatches::UserPatch
end
