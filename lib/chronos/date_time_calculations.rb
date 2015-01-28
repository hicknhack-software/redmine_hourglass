module Chronos::DateTimeCalculations
  class InvalidIntervalsException < StandardError
  end

  class NoFittingPossibleException < StandardError
  end

  class TimeInfinity < DateTime::Infinity
    def <=>(anOther)
      super anOther.to_i
    rescue
      super
    end
    def to_i
      to_f
    end
    def eql?(other)
      to_f.eql? other.to_f
    end
  end

  class << self
    def round_limit
      Chronos.settings[:round_limit].to_f / 100
    end

    def round_limit_in_seconds
      (round_limit * round_minimum).to_i
    end

    def round_minimum
      Chronos.settings[:round_minimum].to_f.hours.to_i
    end

    def time_diff(time1, time2)
      (time2 - time1).abs.to_i
    end

    def round_interval(time_interval)
      if time_interval % round_minimum != 0
        round_multiplier = (time_interval % round_minimum < round_limit_in_seconds ? 0 : 1)
        (time_interval.to_i / round_minimum + round_multiplier) * round_minimum
      else
        time_interval
      end
    end

    def fit_in_bounds(start, stop, start_limit, stop_limit)
      time_interval = time_diff(start, stop)
      raise InvalidIntervalsException if stop_limit <= start_limit || stop <= start
      raise NoFittingPossibleException if time_diff(start_limit, stop_limit) < time_interval
      return [stop_limit - time_interval, stop_limit] if stop_limit < stop
      return [start_limit, start_limit + time_interval] if start_limit > start
      [start, stop]
    end

    def limits_from_overlapping_intervals(start, stop, records, delta = 0)
      latest_start = TimeInfinity.new -1
      earliest_stop = TimeInfinity.new
      records.each do |record|
        latest_start = record.stop if record.stop < start + delta && record.stop > latest_start
        earliest_stop = record.start if record.start > stop - delta && record.start < earliest_stop
      end
      [latest_start, earliest_stop]
    end
  end
end