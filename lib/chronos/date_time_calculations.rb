module Chronos::DateTimeCalculations
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

    def time_diff(start, stop)
      (stop - start).to_i
    end

    def round_interval(start, stop)
      time_interval = time_diff start, stop
      if time_interval % round_minimum != 0
        round_multiplier = (time_interval % round_minimum < round_limit_in_seconds ? 0 : 1)
        time_interval = (time_interval.to_i / round_minimum + round_multiplier) * round_minimum
      end
      time_interval
    end

    def fit_in_bounds(start, latest_start, stop, earliest_stop)
      time_interval = time_diff(start, stop)
      raise 'doesn\'t fit' if time_diff(latest_start, earliest_stop) < time_interval
      return [earliest_stop - time_interval, earliest_stop] if earliest_stop < stop
      return [latest_start, latest_start + time_interval] if latest_start > start
      [start, stop]
    end

    def limits_from_overlapping_intervals(start, stop, records, delta = 0)
      latest_start = Time.at 0
      earliest_stop = Time.now + 100.years #something in the far future as there is no properly working time infinity
      records.each do |record|
        latest_start = record.stop if record.stop < start + delta && record.stop > latest_start
        earliest_stop = record.start if record.start > stop - delta && record.start < earliest_stop
      end
      [latest_start, earliest_stop]
    end
  end
end