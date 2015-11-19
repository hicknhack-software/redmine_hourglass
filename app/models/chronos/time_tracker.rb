module Chronos
  class TimeTracker < ActiveRecord::Base
    include Namespace

    belongs_to :user
    belongs_to :project
    belongs_to :issue
    belongs_to :activity, class_name: 'TimeEntryActivity', foreign_key: 'activity_id'

    after_initialize :init
    before_save :sync_issue_and_project

    validates_uniqueness_of :user_id
    validates_presence_of :user, :start
    validates_presence_of :project, if: :project_id?
    validates_presence_of :issue, if: :issue_id?
    validates_presence_of :activity, if: :activity_id?
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
          time_log.book time_booking_params if bookable?
        end
        destroy if !time_log || time_log.persisted?
      end
      time_log
    end

    private
    def init
      self.user ||= User.current
      self.round = Chronos.settings[:round_default] if round.nil?
      self.start ||= Time.now.change sec: 0
    end

    def sync_issue_and_project
      self.project_id = issue.project_id if issue.present?
    end

    def time_log_params
      attributes.with_indifferent_access.slice :start, :user_id, :comments
    end

    def time_booking_params
      attributes.with_indifferent_access.slice :project_id, :issue_id, :activity_id, :round
    end

    def bookable?
      project.present? && activity_id.present?
    end
  end
end