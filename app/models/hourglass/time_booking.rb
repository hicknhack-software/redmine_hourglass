module Hourglass
  class TimeBooking < ApplicationRecord
    include Namespace
    include ProjectIssueSyncing

    belongs_to :time_log
    belongs_to :time_entry, dependent: :destroy
    has_one :user, through: :time_log
    has_one :project, through: :time_entry
    has_one :issue, through: :time_entry
    has_one :activity, through: :time_entry
    has_one :fixed_version, through: :issue

    accepts_nested_attributes_for :time_entry
    accepts_nested_attributes_for :time_log

    after_initialize :fix_nil_hours
    after_validation :filter_time_entry_invalid_error
    after_save :save_custom_field_values

    validates_presence_of :time_log, :time_entry, :start, :stop
    validate :stop_is_valid
    validates_associated :time_entry

    delegate :id, to: :issue, prefix: true, allow_nil: true
    delegate :id, to: :activity, prefix: true, allow_nil: true
    delegate :id, to: :project, prefix: true, allow_nil: true
    delegate :id, to: :user, prefix: true, allow_nil: true
    delegate :comments, :comments=, :hours, :project_id=, :save_custom_field_values, to: :time_entry, allow_nil: true

    scope :visible, lambda { |*args| joins(:project).where(projects: {id: visible_condition(args.shift || User.current, *args)})
    }

    def update(args = {})
      if args[:time_entry_attributes].present? && time_entry.present?
        args[:time_entry_attributes].merge! id: time_entry_id
      end
      if args[:time_log_attributes].present? && time_log.present?
        args[:time_log_attributes].merge! id: time_log_id
      end
      super args
    end

    def rounding_carry_over
      (stop - time_log.stop).to_i
    end

    def as_json(args = {})
      includes = [:time_entry]
      includes << :time_log if include_time_log?
      super({include: includes}.deep_merge args)
    end

    def include_time_log!
      @include_time_log = true
    end

    private
    def self.visible_condition(user, _options = {})
      project_ids = Project.allowed_to(user, :hourglass_view_booked_time).pluck :id
      project_ids += Project.allowed_to(user, :hourglass_view_own_booked_time).pluck :id
      project_ids.uniq
    end

    def fix_nil_hours
      time_entry.hours ||= 0 if time_entry && time_entry.activity_id.blank? #redmine sets hours to nil, if it's 0 on initializing
    end

    def filter_time_entry_invalid_error
      self.errors.delete(:time_entry)
      self.errors.messages.transform_keys! {|k| k == :'time_entry.base' ? :base : k}
    end

    def stop_is_valid
      #this is different from the stop validation of time log
      errors.add :stop, :invalid if stop.present? && start.present? && stop < start
    end

    def include_time_log?
      @include_time_log
    end
  end
end
