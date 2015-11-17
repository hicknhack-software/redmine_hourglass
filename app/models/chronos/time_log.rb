module Chronos
  class TimeLog < ActiveRecord::Base
    include Chronos::Namespace

    belongs_to :user
    has_many :time_bookings, dependent: :destroy
    has_many :time_entries, through: :time_bookings

    validates_presence_of :user, :start, :stop
    validates_length_of :comments, maximum: 255, allow_blank: true
    validate :stop_is_valid

    scope :booked_on_project, lambda { |project_id|
                              joins(:time_entries).where(time_entries: {project_id: project_id})
                            }
    scope :with_start_in_interval, lambda { |floor, ceiling|
                        where(arel_table[:start].gt(floor).and(arel_table[:start].lt(ceiling)))
                      }

    def book(args = {})
      args.reverse_merge! default_booking_arguments
      if args[:round]
        previous_time_log = previous_booked_time_log args
        next_time_log = next_booked_time_log args
        adjustment = previous_time_log && previous_time_log.time_bookings.first.rounding_carry_over || 0 #todo:remove first or solve for multiple bookings
        args[:start] = args[:start] + adjustment
        amount = DateTimeCalculations.time_diff args[:start], args[:stop]
        args[:stop] = args[:start] + DateTimeCalculations.round_interval(amount - adjustment)
      end
      TimeBooking.create time_bookings_arguments args
    end

    private
    def next_booked_time_log(args)
      user.chronos_time_logs.booked_on_project(args[:project_id]).with_start_in_interval(args[:start], args[:start] + DateTimeCalculations.round_carry_over_due).order(:start).first
    end

    def previous_booked_time_log(args)
      user.chronos_time_logs.booked_on_project(args[:project_id]).with_start_in_interval(args[:start] - DateTimeCalculations.round_carry_over_due, args[:start]).order(:start).last
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
  end
end