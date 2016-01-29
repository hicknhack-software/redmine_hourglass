module Chronos
  class TimeBooking < ActiveRecord::Base
    include Namespace
    include ProjectIssueSyncing

    belongs_to :time_log
    belongs_to :time_entry, dependent: :delete
    has_one :user, through: :time_log
    has_one :project, through: :time_entry
    has_one :issue, through: :time_entry
    has_one :activity, through: :time_entry
    has_one :fixed_version, through: :issue

    accepts_nested_attributes_for :time_entry

    after_initialize :fix_nil_hours
    after_validation :filter_time_entry_invalid_error

    validates_presence_of :time_log, :time_entry, :start, :stop
    validate :stop_is_valid
    validates_associated :time_entry

    delegate :id, to: :issue, prefix: true, allow_nil: true
    delegate :id, to: :activity, prefix: true, allow_nil: true
    delegate :id, to: :project, prefix: true, allow_nil: true
    delegate :id, to: :user, prefix: true, allow_nil: true
    delegate :comments, :hours, :project_id=, to: :time_entry, allow_nil: true

    def rounding_carry_over
      (stop - time_log.stop).to_i
    end

    def to_json(args = {})
      super args.deep_merge include: :time_entry
    end

    private
    def fix_nil_hours
      time_entry.hours ||= 0 if time_entry && time_entry.activity_id.blank? #redmine sets hours to nil, if it's 0 on initializing
    end

    def filter_time_entry_invalid_error
      self.errors.delete :time_entry
    end

    def stop_is_valid
      #this is different from the stop validation of time log
      errors.add :stop, :invalid if stop.present? && start.present? && stop < start
    end
  end
end
