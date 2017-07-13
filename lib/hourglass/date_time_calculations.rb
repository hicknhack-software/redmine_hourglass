module Hourglass::DateTimeCalculations
  class << self
    def round_limit_in_seconds(project: nil)
      ((Hourglass::Settings[:round_limit, project: project].to_f / 100) * round_minimum(project: project)).to_i
    end

    def round_minimum(project: nil)
      Hourglass::Settings[:round_minimum, project: project].to_f.hours.to_i
    end

    def round_carry_over_due(project: nil)
      Hourglass::Settings[:round_carry_over_due, project: project].to_f.hours.to_i
    end

    def time_diff(time1, time2)
      (time1 - time2).abs.to_i
    end

    def time_diff_in_hours(time1, time2)
      in_hours time_diff time1, time2
    end

    def in_hours(time_diff)
      time_diff / 1.hour.to_f
    end

    def hours_in_units(hours)
      [60, 60].inject([hours * 3600]) {|result, unitsize|
        result[0, 0] = result.shift.divmod unitsize
        result
      }
    end

    def round_interval(time_interval, project: nil)
      round_minimum_value = round_minimum project: project
      if time_interval % round_minimum_value != 0
        round_multiplier = (time_interval % round_minimum_value < round_limit_in_seconds(project: project) ? 0 : 1)
        (time_interval.to_i / round_minimum_value + round_multiplier) * round_minimum_value
      else
        time_interval
      end
    end

    def calculate_bookable_time(start, stop, round_carry_over = 0, project: nil)
      start += round_carry_over || 0
      stop = start + round_interval(time_diff(start, stop), project: project)
      [start, stop]
    end

    def booking_process(user, options)
      round = round?(options)
      if round
        previous_time_log = closest_booked_time_log user, options[:project_id], options[:start], after_current: false
        options[:start], options[:stop] = calculate_bookable_time options[:start], options[:stop], previous_time_log && previous_time_log.time_booking && previous_time_log.time_booking.rounding_carry_over, project: options[:project_id]
      end
      time_booking = nil
      ActiveRecord::Base.transaction(requires_new: true) do
        time_booking = yield options
        raise ActiveRecord::Rollback unless time_booking.persisted?
        update_following_bookings user, options[:project_id], time_booking if round
      end
      time_booking
    end

    def update_following_bookings(user, project_id, current_booking)
      booking = current_booking
      current_time_log = current_booking.time_log
      start = current_time_log.start
      loop do
        next_time_log = closest_booked_time_log user, project_id, start, after_current: true
        break if !next_time_log || current_time_log == next_time_log
        start, stop = calculate_bookable_time next_time_log.start, next_time_log.stop, booking && booking.rounding_carry_over
        booking = next_time_log.time_booking
        booking.update start: start, stop: stop, time_entry_attributes: {hours: time_diff_in_hours(start, stop)}
        raise ActiveRecord::Rollback unless booking.persisted?
        current_time_log = next_time_log
      end
    end

    def closest_booked_time_log(user, project_id, start, after_current: false)
      round_carry_over_due_value = round_carry_over_due project: project_id
      interval = after_current ? [start, start + round_carry_over_due_value] : [start - round_carry_over_due_value, start]
      closest_time_logs = user.hourglass_time_logs
                              .booked_on_project(project_id)
                              .with_start_in_interval(*interval)
                              .order(:start)
      after_current ? closest_time_logs.first : closest_time_logs.last
    end

    private
    def round?(options)
      (options[:round].nil? ? Hourglass::Settings[:round_default, project: options[:project_id]] : options[:round]) &&
          !Hourglass::Settings[:round_sums_only, project: options[:project_id]]
    end
  end
end
