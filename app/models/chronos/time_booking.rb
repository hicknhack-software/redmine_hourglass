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

    delegate :issue, :issue_id,
             :project, :project_id,
             :activity, :activity_id,
             :user, :user_id,
             :comments,
             to: :time_entry

    def rounding_carry_over
      (stop - time_log.stop).to_i
    end

    private
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

    def stop_is_valid
      #this is different from the stop validation of time log
      errors.add :stop, :invalid if stop.present? && start.present? && stop < start
    end
  end
end
