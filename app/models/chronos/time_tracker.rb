module Chronos
  class TimeTracker < ActiveRecord::Base
    include Namespace
    include ProjectIssueSyncing

    belongs_to :user
    belongs_to :project
    belongs_to :issue
    belongs_to :activity, class_name: 'TimeEntryActivity', foreign_key: 'activity_id'

    after_initialize :init
    before_update if: :project_id_changed? do
      update_round project
      true
    end

    validates_uniqueness_of :user_id
    validates_presence_of :user, :start
    validates_presence_of :project, if: Proc.new { |tt| tt.project_id.present? }
    validates_presence_of :issue, if: Proc.new { |tt| tt.issue_id.present? }
    validates_presence_of :activity, if: Proc.new { |tt| tt.activity_id.present? }
    validates_length_of :comments, maximum: 255, allow_blank: true

    class << self
      alias_method :start, :create
    end

    def stop
      stop = Time.now.change(sec: 0) + 1.minute
      time_log = nil
      ActiveRecord::Base.transaction do
        if start < stop
          time_log = TimeLog.create time_log_params.merge stop: stop
          raise ActiveRecord::Rollback unless time_log.persisted?
          time_booking = bookable? ? time_log.book(time_booking_params) : nil
          raise ActiveRecord::Rollback if time_booking && !time_booking.persisted?
        end
        destroy
      end
      time_log
    end

    def hours
      DateTimeCalculations.time_diff_in_hours start, Time.now.change(sec: 0) + 1.minute
    end

    private
    def init
      current_user = User.current
      now = Time.now.change sec: 0
      previous_time_log = current_user.chronos_time_logs.find_by(stop: now + 1.minute)
      self.user ||= current_user
      update_round project_id || issue && issue.project_id unless round.present?

      self.start ||= previous_time_log && previous_time_log.stop || now
    end

    def time_log_params
      attributes.with_indifferent_access.slice :start, :user_id, :comments
    end

    def time_booking_params
      attributes.with_indifferent_access.slice :project_id, :issue_id, :activity_id, :round
    end

    def bookable?
      project.present?
    end

    def update_round(project = nil)
      self.round = !Chronos::Settings[:round_sums_only, project: project] && Chronos::Settings[:round_default, project: project]
    end
  end
end
