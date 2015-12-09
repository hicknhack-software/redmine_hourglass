module ChronosImport
  class RedmineTimeTracker
    def self.import!
      unless Redmine::Plugin.all.any? {|plugin| plugin.id == :redmine_time_tracker}
        raise('Can\'t import your data from Redmine Time Tracker, the plugin is not installed.')
      end

      ActiveRecord::Base.transaction do
        TimeTracker.all.each do |time_tracker|
          Chronos::TimeTracker.create!(
              start:       time_tracker.start_time,
              comments:    time_tracker.comments,
              round:       time_tracker.round,
              user_id:     time_tracker.user_id,
              project_id:  time_tracker.project_id,
              issue_id:    time_tracker.issue_id,
              activity_id: time_tracker.activity_id
          )
        end

        time_log_id_mapping = {}

        TimeLog.all.each do |time_log|
          new_log = Chronos::TimeLog.create!(
              start:    time_log.started_on,
              stop:     time_log.stopped_at,
              comments: time_log.comments,
              user_id:  time_log.user_id
          )

          time_log_id_mapping[time_log.id] = new_log.id
        end

        TimeBooking.all.each do |time_booking|
          Chronos::TimeBooking.create!(
              start:         time_booking.started_on,
              stop:          time_booking.stopped_at,
              time_log_id:   time_log_id_mapping[time_booking.time_log.id],
              time_entry_id: time_booking.time_entry_id
          )
        end
      end
    end
  end
end
