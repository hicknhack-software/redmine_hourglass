module Chronos
  class TimeBooking < ActiveRecord::Base
    include Namespace
    include StartDate

    belongs_to :time_log
    belongs_to :time_entry, dependent: :delete
    has_one :user, through: :time_log
    has_one :project, through: :time_entry
    has_one :issue, through: :time_entry
    has_one :activity, through: :time_entry
    has_one :fixed_version, through: :issue

    after_initialize :create_time_entry
    after_update :update_time_entry
    after_validation :add_time_entry_errors

    attr_accessor :time_entry_arguments

    validates_presence_of :time_log, :time_entry, :start, :stop
    validate :stop_is_valid
    validates_associated :time_entry

    delegate :id, to: :issue, prefix: true, allow_nil: true
    delegate :id, to: :activity, prefix: true, allow_nil: true
    delegate :id, to: :project, prefix: true, allow_nil: true
    delegate :id, to: :user, prefix: true, allow_nil: true
    delegate :comments, :hours, to: :time_entry, allow_nil: true

    def rounding_carry_over
      (stop - time_log.stop).to_i
    end

    def to_json(args = {})
      super args.deep_merge include: :time_entry
    end

    private
    def create_time_entry
      if time_entry_arguments.present? && !time_entry
        time_entry = super time_entry_arguments
        time_entry.hours ||= 0 #redmine sets hours to nil, if it's 0 on initializing
        time_entry.save
      end
    end

    def update_time_entry
      if time_entry_arguments.present? && time_entry
        time_entry.update time_entry_arguments
      end
    end

    def add_time_entry_errors
      filtered_errors = self.errors.reject { |err| err.first == :time_entry }
      self.errors.clear
      filtered_errors.each { |err| self.errors.add(*err) }
      time_entry.errors.full_messages.each { |msg| errors.add :base, msg } if time_entry.present?
    end

    def stop_is_valid
      #this is different from the stop validation of time log
      errors.add :stop, :invalid if stop.present? && start.present? && stop < start
    end
  end
end
