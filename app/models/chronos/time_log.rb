module Chronos
  class TimeLog < ActiveRecord::Base
    include Chronos::Namespace
    include Chronos::StopValidation

    belongs_to :user
    has_many :time_bookings, dependent: :destroy
    has_many :time_entries, through: :time_bookings

    validates_presence_of :user, :start, :stop
    validates_length_of :comments, maximum: 255, allow_blank: true
    validate :stop_is_valid

    def book(args = {})
      args.reverse_merge! default_booking_arguments
      bookings = user.chronos_time_bookings.overlaps_with(args[:start], args[:stop], DateTimeCalculations.round_limit_in_seconds).all
      latest_start, earliest_stop = DateTimeCalculations.limits_from_overlapping_intervals args[:start], args[:stop], bookings

      args[:stop] = args[:start] + DateTimeCalculations.round_interval(DateTimeCalculations.time_diff args[:start], args[:stop]) if args[:round]
      args[:start], args[:stop] = DateTimeCalculations.fit_in_bounds args[:start], args[:stop], latest_start, earliest_stop

      TimeBooking.create time_bookings_arguments args
    end

    private
    def default_booking_arguments
      {start: start, stop: stop, comments: comments, time_log_id: id, user: user}
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
  end
end