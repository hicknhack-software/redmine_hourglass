class Hourglass::RedmineTimeTrackerImport
  class << self
    def start!
      check_for_plugin!

      TimeTracker.all.each do |time_tracker|
        new_time_tracker = Hourglass::TimeTracker.find_or_initialize_by(
            user_id: time_tracker.user_id
        )
        new_time_tracker.attributes = {
            start: time_tracker.started_on,
            comments: time_tracker.comments,
            round: time_tracker.round,
            project_id: time_tracker.project_id,
            issue_id: time_tracker.issue_id,
            activity_id: time_tracker.activity_id
        }
        log_errors time_tracker, new_time_tracker unless new_time_tracker.save
      end

      TimeBooking.all.each do |time_booking|
        new_time_booking = Hourglass::TimeBooking.find_or_initialize_by(
            time_entry_id: time_booking.time_entry_id
        )
        time_log_attributes = {
            start: time_booking.started_on,
            stop: time_booking.stopped_at,
            comments: time_booking.time_log.comments,
            user_id: time_booking.time_log.user_id
        }
        # time_log_attributes[:id] = new_time_booking.time_log_id if new_time_booking.persisted?
        new_time_booking.attributes = {
            start: time_booking.started_on,
            stop: time_booking.stopped_at,
            time_log_attributes: time_log_attributes
        }
        log_errors time_booking, new_time_booking unless new_time_booking.save
      end

      TimeLog.all.each do |time_log|
        if time_log.time_bookings.empty?
          create_new_time_log time_log
        elsif time_log.bookable_hours > 0
          find_gaps(time_log.time_bookings, time_log.started_on, time_log.stopped_at).each do |gap|
            create_new_time_log time_log, *gap
          end
        end
      end
    end

    private
    def create_new_time_log(time_log, start = time_log.started_on, stop = time_log.stopped_at)
      new_time_log = Hourglass::TimeLog.find_or_initialize_by(
          start: start,
          stop: stop,
          user_id: time_log.user_id
      )
      new_time_log.attributes = {
          comments: time_log.comments
      }
      log_errors time_log, new_time_log unless new_time_log.save
    end

    def log_errors(old, new)
      puts "There was a problem while importing #{old.class.name} #{old.id}:"
      puts "Attributes: #{old.attributes.to_json}"
      puts "Errors: #{new.errors.full_messages.to_sentence}."
      if new.errors.count == 1 && (new.respond_to?(:time_log) ? new.time_log.errors.added?(:base, :overlaps) : new.errors.added?(:base, :overlaps))
        new.save validate: false
        puts 'It was added nevertheless, delete it yourself if you want it removed.'
        puts "New record: #{new.attributes.to_json}"
      end
      puts '-------------------'
    end

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
