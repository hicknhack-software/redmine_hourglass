require_relative '../spec_helper'
describe Chronos::DateTimeCalculations do
  it 'gives the round minimum in seconds' do
    Chronos::Settings[:round_minimum] = '0.4'
    expect(Chronos::DateTimeCalculations.round_minimum).to eql 1440
  end

  it 'gives the round limit as number' do
    Chronos::Settings[:round_limit] = '80'
    expect(Chronos::DateTimeCalculations.round_limit).to eql 0.8
  end

  it 'gives the round limit in seconds' do
    Chronos::Settings[:round_limit] = '70'
    Chronos::Settings[:round_minimum] = '0.3'
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

  describe 'round_interval function' do
    round_minimum_in_seconds = 1800
    round_limits_in_seconds = 1620

    before :each do
      Chronos::Settings[:round_minimum] = '0.5'
      Chronos::Settings[:round_limit] = '90'
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
end
