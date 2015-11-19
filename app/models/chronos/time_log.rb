module Chronos
  class TimeLog < ActiveRecord::Base
    include Chronos::Namespace

    belongs_to :user
    has_many :time_bookings, dependent: :destroy
    has_many :time_entries, through: :time_bookings

    validates_presence_of :user, :start, :stop
    validates_length_of :comments, maximum: 255, allow_blank: true
    validate :stop_is_valid
    validate :does_not_overlap_with_other

    scope :booked_on_project, lambda { |project_id|
                              joins(:time_entries).where(time_entries: {project_id: project_id})
                            }
    scope :with_start_in_interval, lambda { |floor, ceiling|
                                   where(arel_table[:start].gt(floor).and(arel_table[:start].lt(ceiling)))
                                 }

    scope :overlaps_with, lambda { |start, stop|
                          where(arel_table[:start].lt(stop).and(arel_table[:stop].gt(start)))
                        }

    def book(args = {})
      args.reverse_merge! default_booking_arguments
      if args[:round]
        previous_time_log = previous_booked_time_log args
        args[:start], args[:stop] = calculate_bookable_time args, previous_time_log && previous_time_log.time_bookings.first
      end
      booking = nil
      ActiveRecord::Base.transaction do
        booking = TimeBooking.create! time_bookings_arguments args
        update_following_bookings args, booking if args[:round]
      end
      booking
    end

    private
    def update_following_bookings(args, self_booking)
      booking = self_booking
      last_time_log = self
      args.merge! start: start, stop: stop
      loop do
        next_time_log = next_booked_time_log args
        break if !next_time_log || last_time_log == next_time_log
        args.merge! start: next_time_log.start, stop: next_time_log.stop
        start, stop = calculate_bookable_time args, booking
        booking = next_time_log.time_bookings.first
        booking.update! start: start, stop: stop, time_entry_arguments: {hours: DateTimeCalculations.time_diff(start, stop) / 1.hour.to_f}
        last_time_log = next_time_log
      end
    end

    def next_booked_time_log(args)
      user.chronos_time_logs.booked_on_project(args[:project_id]).with_start_in_interval(args[:start], args[:start] + DateTimeCalculations.round_carry_over_due).order(:start).first
    end

    def previous_booked_time_log(args)
      user.chronos_time_logs.booked_on_project(args[:project_id]).with_start_in_interval(args[:start] - DateTimeCalculations.round_carry_over_due, args[:start]).order(:start).last
    end

    def calculate_bookable_time(args, booking)
      adjustment = booking && booking.rounding_carry_over || 0 #todo:remove first or solve for multiple bookings
      start = args[:start] + adjustment
      amount = DateTimeCalculations.time_diff start, args[:stop]
      stop = start + DateTimeCalculations.round_interval(amount - adjustment)
      [start, stop]
    end

    def default_booking_arguments
      {start: start, stop: stop, comments: comments, time_log_id: id, user: user, round: Chronos.settings[:round_default] == 'true'}
    end

    def time_bookings_arguments(args)
      args
          .slice(:start, :stop, :time_log_id)
          .merge time_entry_arguments: time_entry_arguments(args)
    end

    def time_entry_arguments(args)
      args
          .slice(:project_id, :issue_id, :comments, :activity_id, :user)
          .merge spent_on: args[:start].to_date, hours: DateTimeCalculations.time_diff(args[:start], args[:stop]) / 1.hour.to_f
    end

    def stop_is_valid
      errors.add :stop, :invalid if stop.present? && start.present? && stop <= start
    end

    def does_not_overlap_with_other
      overapping_time_logs = user.chronos_time_logs.overlaps_with start, stop
      errors.add :base, :overlaps unless overapping_time_logs.empty?
    end
  end
end