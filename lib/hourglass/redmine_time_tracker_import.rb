class Hourglass::RedmineTimeTrackerImport
  class << self
    def start!
      check_for_plugin!

      TimeTracker.all.each do |time_tracker|
        Hourglass::TimeTracker.create(
            start: time_tracker.started_on,
            comments: time_tracker.comments,
            round: time_tracker.round,
            user_id: time_tracker.user_id,
            project_id: time_tracker.project_id,
            issue_id: time_tracker.issue_id,
            activity_id: time_tracker.activity_id
        )
      end

      TimeLog.all.each do |time_log|
        bookings = time_log.time_bookings.map do |time_booking|
          Hourglass::TimeBooking.create(
              start: time_booking.started_on,
              stop: time_booking.stopped_at,
              time_entry_id: time_booking.time_entry_id,
              time_log_attributes: {
                  start: time_booking.started_on,
                  stop: time_booking.stopped_at,
                  comments: time_log.comments,
                  user_id: time_log.user_id
              }
          )
        end

        if time_log.bookable_hours > 0
          if bookings.empty?
            Hourglass::TimeLog.create(
                start: time_log.started_on,
                stop: time_log.stopped_at,
                comments: time_log.comments,
                user_id: time_log.user_id
            )
          else
            find_gaps(bookings, time_log.started_on, time_log.stopped_at).each do |gap|
              Hourglass::TimeLog.create(
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
      unless Redmine::Plugin.installed? :redmine_time_tracker
        Object.const_set :TimeTracker, Class.new(ActiveRecord::Base) unless const_defined?(:TimeTracker)
        unless const_defined?(:TimeLog)
          time_log = Class.new ActiveRecord::Base do
            has_many :time_bookings
            def hours_spent
              ((started_on.to_i - stopped_at.to_i) / 3600.0).to_f
            end

            def bookable_hours
              hours_spent - hours_booked
            end

            def hours_booked
              time_booked = 0
              time_bookings.each do |tb|
                time_booked += tb.hours_spent
              end
              time_booked
            end
          end
          Object.const_set :TimeLog, time_log
        end
        unless const_defined?(:TimeBooking)
          time_booking = Class.new ActiveRecord::Base do
            belongs_to :time_log
            def hours_spent
              ((started_on.to_i - stopped_at.to_i) / 3600.0).to_f
            end
          end
          Object.const_set :TimeBooking, time_booking
        end
      end
    end
  end
end
