module Chronos
  class TimeBooking < ActiveRecord::Base
    include Chronos::Namespace

    belongs_to :time_log
    belongs_to :time_entry, dependent: :delete

    after_initialize :create_time_entry
    after_update :update_time_entry

    attr_accessor :time_entry_arguments

    validates_presence_of :time_log, :time_entry, :start, :stop
    validate :stop_is_valid
    validates_associated :time_entry

    delegate :issue, :project, :activity, :comments, :user, to: :time_entry

    scope :on_project, lambda { |project_id|
                       joins(:time_entry).where(time_entries: {project_id: project_id})
                     }

    scope :overlaps_with, lambda { |start, stop, delta = 0|
                          where(arel_table[:start].lt(stop + delta).and(arel_table[:stop].gt(start - delta)))
                        }

    def create_time_entry
      if time_entry_arguments.present? && !time_entry
        super time_entry_arguments
      end
    end

    def update_time_entry
      if time_entry_arguments.present? && time_entry
        time_entry.update time_entry_arguments
      end
    end

    def rounding_carry_over
      (stop - time_log.stop).to_i
    end

    private
    def stop_is_valid
      #this is different from the stop validation of time log
      errors.add :stop, :invalid if stop.present? && start.present? && stop < start
    end
  end
end