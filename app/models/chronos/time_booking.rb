module Chronos
  class TimeBooking < ActiveRecord::Base
    include Chronos::Namespace
    include Chronos::StopValidation

    belongs_to :time_log
    belongs_to :time_entry, dependent: :delete

    after_initialize :create_time_entry

    attr_accessor :time_entry_arguments

    validates_presence_of :time_log, :time_entry, :start, :stop
    validate :stop_is_valid
    validates_associated :time_entry

    delegate :issue, :project, :activity, :comments, :user, to: :time_entry

    scope :overlaps_with, lambda { |start, stop, delta = 0|
                          where(arel_table[:start].lt(stop + delta).and(arel_table[:stop].gt(start - delta)))
                        }

    def create_time_entry
      if time_entry_arguments.present? && time_entry.nil?
        super time_entry_arguments
      end
    end

    def time_difference_from_time_log
      DateTimeCalculations.time_diff(start, stop) - DateTimeCalculations.time_diff(time_log.start, time_log.stop)
    end
  end
end