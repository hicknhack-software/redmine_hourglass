module Chronos
  class TimeLog < ActiveRecord::Base
    include Chronos::Namespace

    belongs_to :user
    has_one :time_booking, dependent: :destroy
    has_one :time_entry, through: :time_booking

    after_initialize :init

    validates_presence_of :user, :start, :stop
    validates_length_of :comments, maximum: 255, allow_blank: true
    validate :stop_is_valid
    validate :does_not_overlap_with_other, if: [:user, :start?, :stop?]

    scope :booked_on_project, lambda { |project_id|
                              joins(:time_entry).where(time_entries: {project_id: project_id})
                            }
    scope :with_start_in_interval, lambda { |floor, ceiling|
                                   where(arel_table[:start].gt(floor).and(arel_table[:start].lt(ceiling)))
                                 }

    scope :overlaps_with, lambda { |start, stop|
                          where(arel_table[:start].lt(stop).and(arel_table[:stop].gt(start)))
                        }

    def init
      self.start = start.change(sec: 0) if start
      self.stop = stop.change(sec: 0) if stop
    end

    def book(args)
      options = default_booking_arguments.merge args.except(:start, :stop)
      if options[:round]
        previous_time_log = previous_booked_time_log options
        options[:start], options[:stop] = calculate_bookable_time options, previous_time_log && previous_time_log.time_booking
      end
      booking = nil
      ActiveRecord::Base.transaction do
        booking = TimeBooking.create time_booking_arguments options
        update_following_bookings options, booking if options[:round] && booking.persisted?
      end
      booking
    end

    def split(split_at)
      split_at = split_at.change(sec: 0)
      return if start >= split_at || split_at >= stop
      new_time_log = nil
      new_time_log_stop = stop
      ActiveRecord::Base.transaction do
        update stop: split_at
        new_time_log = self.class.create start: split_at, stop: new_time_log_stop, user: user, comments: comments
      end
      new_time_log
    end

    def combine_with(time_log)
      return false if stop != time_log.start || time_booking.present? || time_log.time_booking.present?
      new_stop = time_log.stop
      ActiveRecord::Base.transaction do
        time_log.destroy
        update stop: new_stop
      end
      true
    end

    private
    def update_following_bookings(options, self_booking)
      booking = self_booking
      last_time_log = self
      options.merge! start: start, stop: stop
      loop do
        next_time_log = next_booked_time_log options
        break if !next_time_log || last_time_log == next_time_log
        options.merge! start: next_time_log.start, stop: next_time_log.stop
        start, stop = calculate_bookable_time options, booking
        booking = next_time_log.time_booking
        booking.update start: start, stop: stop, time_entry_arguments: {hours: DateTimeCalculations.time_diff(start, stop) / 1.hour.to_f}
        raise ActiveRecord::Rollback unless booking.persisted?
        last_time_log = next_time_log
      end
    end

    def next_booked_time_log(options)
      user.chronos_time_logs.booked_on_project(options[:project_id]).with_start_in_interval(options[:start], options[:start] + DateTimeCalculations.round_carry_over_due).order(:start).first
    end

    def previous_booked_time_log(options)
      user.chronos_time_logs.booked_on_project(options[:project_id]).with_start_in_interval(options[:start] - DateTimeCalculations.round_carry_over_due, options[:start]).order(:start).last
    end

    def calculate_bookable_time(options, booking)
      adjustment = booking && booking.rounding_carry_over || 0
      start = options[:start] + adjustment
      amount = DateTimeCalculations.time_diff start, options[:stop]
      stop = start + DateTimeCalculations.round_interval(amount)
      [start, stop]
    end

    def default_booking_arguments
      {start: start, stop: stop, comments: comments, time_log_id: id, user: user, round: Chronos.settings[:round_default] == 'true'}
    end

    def time_booking_arguments(options)
      options
          .slice(:start, :stop, :time_log_id)
          .merge time_entry_arguments: time_entry_arguments(options)
    end

    def time_entry_arguments(options)
      options
          .slice(:project_id, :issue_id, :comments, :activity_id, :user)
          .merge spent_on: options[:start].to_date, hours: DateTimeCalculations.time_diff(options[:start], options[:stop]) / 1.hour.to_f
    end

    def stop_is_valid
      errors.add :stop, :invalid if stop.present? && start.present? && stop <= start
    end

    def does_not_overlap_with_other
      overlapping_time_logs = user.chronos_time_logs.where.not(id: id).overlaps_with start, stop
      errors.add :base, :overlaps unless overlapping_time_logs.empty?
    end
  end
end
