require_relative '../spec_helper'
describe Chronos::DateTimeCalculations do
  it 'gives the round minimum in seconds' do
    Chronos.settings[:round_minimum] = '0.4'
    expect(Chronos::DateTimeCalculations.round_minimum).to eql 1440
  end

  it 'gives the round limit as number' do
    Chronos.settings[:round_limit] = '80'
    expect(Chronos::DateTimeCalculations.round_limit).to eql 0.8
  end

  it 'gives the round limit in seconds' do
    Chronos.settings[:round_limit] = '70'
    Chronos.settings[:round_minimum] = '0.3'
    expect(Chronos::DateTimeCalculations.round_limit_in_seconds).to eql 756
  end

  describe 'time_diff function' do
    it 'gives correct result if time2 is greater than time1' do
      time1 = Time.now
      time2 = time1 + 1.hour
      expect(Chronos::DateTimeCalculations.time_diff time1, time2).to eql 3600
    end
    it 'gives correct result if time1 is greater than time2' do
      time1 = Time.now
      time2 = time1 - 1.hour
      expect(Chronos::DateTimeCalculations.time_diff time1, time2).to eql 3600
    end
  end

  describe 'TimeInfinity class' do
    context 'positive value' do
      let (:infinity) { Chronos::DateTimeCalculations::TimeInfinity.new }

      it 'is greater as an arbitrary Time value' do
        expect(infinity > Time.now).to be true
        expect(Time.now < infinity).to be true
      end

      it 'is greater equals an arbitrary Time value' do
        expect(infinity >= Time.now).to be true
        expect(Time.now <= infinity).to be true
      end

      it 'is not equals an arbitrary Time value' do
        expect(infinity == Time.now).to be false
        expect(Time.now == infinity).to be false
        expect(infinity != Time.now).to be true
        expect(Time.now != infinity).to be true
      end

      it 'is not smaller as an arbitrary Time value' do
        expect(infinity < Time.now).to be false
        expect(Time.now > infinity).to be false
      end

      it 'is not smaller equals an arbitrary Time value' do
        expect(infinity <= Time.now).to be false
        expect(Time.now >= infinity).to be false
      end
    end

    context 'negative value' do
      let (:negative_infinity) { Chronos::DateTimeCalculations::TimeInfinity.new(-1) }

      it 'is not greater as an arbitrary Time value' do
        expect(negative_infinity > Time.now).to be false
        expect(Time.now < negative_infinity).to be false
      end

      it 'is not greater equals an arbitrary Time value' do
        expect(negative_infinity >= Time.now).to be false
        expect(Time.now <= negative_infinity).to be false
      end

      it 'is not equals an arbitrary Time value' do
        expect(negative_infinity == Time.now).to be false
        expect(Time.now == negative_infinity).to be false
        expect(negative_infinity != Time.now).to be true
        expect(Time.now != negative_infinity).to be true
      end

      it 'is smaller as an arbitrary Time value' do
        expect(negative_infinity < Time.now).to be true
        expect(Time.now > negative_infinity).to be true
      end

      it 'is smaller equals an arbitrary Time value' do
        expect(negative_infinity <= Time.now).to be true
        expect(Time.now >= negative_infinity).to be true
      end
    end
  end

  describe 'round_interval function' do
    round_minimum_in_seconds = 1800
    round_limits_in_seconds = 1620

    before :all do
      Chronos.settings[:round_minimum] = '0.5'
      Chronos.settings[:round_limit] = '90'
    end

    5.times do
      multiplied_minimum = rand(1..5) * round_minimum_in_seconds
      interval = rand(10...round_limits_in_seconds) + multiplied_minimum
      it "rounds down #{interval}" do
        expect(Chronos::DateTimeCalculations.round_interval interval).to be multiplied_minimum
      end
    end

    5.times do
      multiplier = rand(1..5)
      interval = rand(round_limits_in_seconds + 10...round_minimum_in_seconds) + round_minimum_in_seconds * multiplier
      it "rounds up #{interval}" do
        expect(Chronos::DateTimeCalculations.round_interval interval).to be round_minimum_in_seconds * (multiplier + 1)
      end
    end

    it 'does nothing if interval is on par with the minimum' do
      expect(Chronos::DateTimeCalculations.round_interval round_minimum_in_seconds).to be round_minimum_in_seconds
    end
  end

  describe 'fit_in_bounds function' do
    let (:start) { Time.now }
    let (:stop) { start + 1.hour }
    let (:start_limit) { start - 1.hour }
    let (:stop_limit) { stop + 1.hour }
    let (:interval) { Chronos::DateTimeCalculations.fit_in_bounds start, stop, start_limit, stop_limit }

    context 'with start limitation' do
      let (:start_limit) { start + 2.minutes }

      it 'moves start and stop to fit the limit' do
        expect(interval).to eql [start_limit, stop + (start_limit - start)]
      end
      it 'doesn\'t change the interval' do
        expect(interval[1] - interval[0]).to eql stop - start
      end
    end

    context 'with stop limitation' do
      let (:stop_limit) { stop - 2.minutes }

      it 'moves start and stop to fit the limit' do
        expect(interval).to eql [start - (stop - stop_limit), stop_limit]
      end
      it 'doesn\'t change the interval' do
        expect(interval[1] - interval[0]).to eql stop - start
      end
    end

    context 'with no limitation' do
      it 'returns start and  stop without changing' do
        expect(interval).to eql [start, stop]
      end
    end

    context 'with start and stop limitation' do
      let (:start_limit) { start + 2.minutes }
      let (:stop_limit) { stop - 2.minutes }

      it 'raises an exception' do
        expect { interval }.to raise_error Chronos::DateTimeCalculations::NoFittingPossibleException
      end
    end

    context 'with invalid interval' do
      let (:stop) { start - 1.hour }

      it 'raises an exception' do
        expect { interval }.to raise_error Chronos::DateTimeCalculations::InvalidIntervalsException
      end
    end

    context 'with invalid limit interval' do
      let (:stop_limit) { start_limit - 1.hour }

      it 'raises an exception' do
        expect { interval }.to raise_error Chronos::DateTimeCalculations::InvalidIntervalsException
      end
    end
  end

  describe 'limits_from_overlapping_intervals function' do
    class TimeRecord
      attr_accessor :start, :stop

      def initialize(start, stop)
        @start = start
        @stop = stop
      end

      def eql?(other)
        start.eql?(other[0]) && stop.eql?(other[1])
      end
    end

    let (:record_7_00_7_30) { TimeRecord.new(Time.new(2015, 01, 28, 7, 00), Time.new(2015, 01, 28, 7, 30)) }
    let (:record_7_30_8_00) { TimeRecord.new(Time.new(2015, 01, 28, 7, 30), Time.new(2015, 01, 28, 8, 0)) }
    let (:record_7_30_8_15) { TimeRecord.new(Time.new(2015, 01, 28, 7, 30), Time.new(2015, 01, 28, 8, 15)) }
    let (:record_7_45_8_45) { TimeRecord.new(Time.new(2015, 01, 28, 7, 45), Time.new(2015, 01, 28, 8, 45)) }
    let (:record_8_15_8_45) { TimeRecord.new(Time.new(2015, 01, 28, 8, 15), Time.new(2015, 01, 28, 8, 45)) }
    let (:record_8_30_9_00) { TimeRecord.new(Time.new(2015, 01, 28, 8, 30), Time.new(2015, 01, 28, 9, 0)) }
    let (:record_9_00_9_30) { TimeRecord.new(Time.new(2015, 01, 28, 9, 00), Time.new(2015, 01, 28, 9, 30)) }
    let (:infinite_limits) { [Chronos::DateTimeCalculations::TimeInfinity.new(-1), Chronos::DateTimeCalculations::TimeInfinity.new] }
    let (:limits) { Chronos::DateTimeCalculations.limits_from_overlapping_intervals record_7_45_8_45.start, record_7_45_8_45.stop, records }

    context 'with no records' do
      let (:records) { [] }

      it 'returns infinite limits' do
        expect(limits).to eql infinite_limits
      end
    end

    context 'with not overlapping records' do
      let (:records) { [record_7_00_7_30, record_9_00_9_30] }

      it 'returns infinite limits' do
        expect(limits).to eql infinite_limits
      end
    end

    context 'with overlapping records before and after' do
      let (:records) { [record_7_30_8_00, record_8_30_9_00] }

      it 'returns correct limits' do
        expect(limits).to eql [record_7_30_8_00.stop, record_8_30_9_00.start]
      end
    end

    context 'with an overlapping record before' do
      let (:records) { [record_7_30_8_00] }

      it 'return correct limits' do
        expect(limits).to eql [record_7_30_8_00.stop, Chronos::DateTimeCalculations::TimeInfinity.new]
      end

    end

    context 'with an overlapping record before' do
      let (:records) { [record_8_30_9_00] }

      it 'return correct limits' do
        expect(limits).to eql [Chronos::DateTimeCalculations::TimeInfinity.new(-1), record_8_30_9_00.start]
      end
    end

    context 'with multiple overlapping records around' do
      let (:records) { [record_7_30_8_00, record_7_30_8_15, record_7_45_8_45, record_8_30_9_00] }

      it 'return correct limits' do
        expect(limits).to eql [record_7_30_8_15.stop, record_7_45_8_45.start]
      end
    end
  end
end
