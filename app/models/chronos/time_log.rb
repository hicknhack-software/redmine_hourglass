module Chronos
  class TimeLog < ActiveRecord::Base
    include Namespace
    include Chronos::StopValidation
    include ActiveModel::ForbiddenAttributesProtection
    unloadable

    belongs_to :user
    has_many :time_bookings, dependent: :destroy
    has_many :time_entries, through: :time_bookings

    validates_presence_of :user, :start, :stop
    validates_length_of :comments, maximum: 255, allow_blank: true
    validate :stop_is_valid

    def book(args = {})
      args.reverse_merge! default_booking_arguments
      args[:time_diff] = DateTimeCalculations.time_diff args[:start], args[:stop]
      args[:time_diff] = DateTimeCalculations.round_interval args[:time_diff] if args[:round]
      bookings = user.chronos_time_bookings.overlaps_with(args[:start], args[:stop], DateTimeCalculations.round_limit_in_seconds).all

      latest_start, earliest_stop = DateTimeCalculations.limits_from_overlapping_intervals args[:start], args[:stop], bookings, DateTimeCalculations.round_limit_in_seconds
      args[:start], args[:stop] = DateTimeCalculations.fit_in_bounds args[:start], latest_start, args[:stop], earliest_stop, args[:time_diff]

      TimeBooking.create time_bookings_arguments(args)
    end

    private
    def default_booking_arguments
      {start: start, stop: stop, comments: comments, time_log_id: id, user_id: user_id}
    end

    def time_bookings_arguments(args)
      args
          .slice(:start, :stop, :time_log_id)
          .merge time_entry_arguments: time_entry_arguments(args)
    end

    def time_entry_arguments(args)
      args
          .slice(:project_id, :issue_id, :comments, :activity_id, :user_id)
          .merge spent_on: args[:start].to_date, hours: args[:time_diff] / 3600.0
    end
  end
end