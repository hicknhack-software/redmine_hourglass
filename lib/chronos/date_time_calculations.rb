module Chronos::DateTimeCalculations
  class << self
    def round_limit
      Chronos.settings[:round_limit].to_f / 100
    end

    def round_limit_in_seconds
      round_limit * round_minimum
    end

    def round_minimum
      Chronos.settings[:round_minimum].to_f.hours.to_i
    end

    def time_diff(start, stop, round = false)
      time_diff = (stop - start).to_i
      if round
        round_interval time_diff
      else
        time_diff
      end
    end

    def round_interval(time_interval)
      if time_interval % round_minimum != 0
        time_interval = (time_interval / round_minimum + (time_interval % round_minimum < round_minimum * round_limit ? 0 : 1)) * round_minimum
      end
      time_interval
    end

    def fit_in_bounds(start, latest_start, stop, earliest_stop, time_interval = (stop - start).to_i)
      raise 'doesn\'t fit' if earliest_stop - latest_start < time_interval
      if earliest_stop < stop
        stop = earliest_stop
        start = stop - time_interval
      elsif latest_start > start
        start = latest_start
        stop = start + time_interval
      else
        stop = start + time_interval
      end
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