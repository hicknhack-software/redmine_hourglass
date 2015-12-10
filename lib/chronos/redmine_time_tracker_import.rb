class Chronos::RedmineTimeTrackerImport
  class << self
    def start!
      check_for_plugin!

      TimeTracker.all.each do |time_tracker|
        Chronos::TimeTracker.create(
            start: time_tracker.start_time,
            comments: time_tracker.comments,
            round: time_tracker.round,
            user_id: time_tracker.user_id,
            project_id: time_tracker.project_id,
            issue_id: time_tracker.issue_id,
            activity_id: time_tracker.activity_id
        )
      end

      TimeLog.all.each do |time_log|
        bookings = []

        time_log.time_bookings.each do |time_booking|
          bookings << Chronos::TimeBooking.new(
              start: time_booking.started_on,
              stop: time_booking.stopped_at,
              time_entry_id: time_booking.time_entry_id,
              time_log: Chronos::TimeLog.create(
                  start: time_booking.started_on,
                  stop: time_booking.stopped_at,
                  comments: time_log.comments,
                  user_id: time_log.user_id
              )
          )
        end

        bookings.each { |booking| booking.save rescue nil }

        if time_log.bookable_hours > 0
          if bookings.empty?
            Chronos::TimeLog.create(
                start: time_log.started_on,
                stop: time_log.stopped_at,
                comments: time_log.comments,
                user_id: time_log.user_id
            )
          else
            find_gaps(bookings, time_log.started_on, time_log.stopped_at).each do |gap|
              Chronos::TimeLog.create(
                  start: gap[0],
                  stop: gap[1],
                  comments: time_log.comments,
                  user_id: time_log.user_id
              )
            end
          end
        end
      end
    end

    private

    def find_gaps(bookings, start, stop)
      sorted = bookings.sort_by { |booking| booking.start }
      gaps = []

      unless sorted.first.start == start
        gaps << [start, sorted.first.start]
      end

      sorted.each_with_index do |booking, i|
        unless sorted[i + 1].nil?
          unless booking.stop == sorted[i + 1].start
            gaps << [booking.stop, sorted[i + 1].start]
          end
        end
      end

      unless sorted.last.stop == stop
        gaps << [sorted.last.stop, stop]
      end

      gaps
    end

    def check_for_plugin!
      unless Redmine::Plugin.all.any? { |plugin| plugin.id == :redmine_time_tracker }
        raise('Can\'t import your data from Redmine Time Tracker, the plugin is not installed.')
      end
    end
  end
end