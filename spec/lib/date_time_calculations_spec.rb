require_relative '../spec_helper'
describe Hourglass::DateTimeCalculations do

  before :all do
    travel_to Time.new 2015, 2, 2, 15
  end

  after :all do
    travel_back
  end

  it 'gives the round minimum in seconds' do
    Hourglass::SettingsStorage[:round_minimum] = '0.4'
    expect(Hourglass::DateTimeCalculations.round_minimum).to eql 1440
  end

  it 'gives the round limit in seconds' do
    Hourglass::SettingsStorage[:round_limit] = '70'
    Hourglass::SettingsStorage[:round_minimum] = '0.3'
    expect(Hourglass::DateTimeCalculations.round_limit_in_seconds).to eql 756
  end

  it 'gives the round carry over due in seconds' do
    Hourglass::SettingsStorage[:round_carry_over_due] = '12.5'
    expect(Hourglass::DateTimeCalculations.round_carry_over_due).to eql 45000
  end

  it 'gives the clamp limit in seconds' do
    Hourglass::SettingsStorage[:clamp_limit] = '5'
    expect(Hourglass::DateTimeCalculations.clamp_limit).to eql 18000
  end

  describe 'time_diff function' do
    it 'gives correct result if time2 is greater than time1' do
      time1 = Time.now
      time2 = time1 + 1.hour
      expect(Hourglass::DateTimeCalculations.time_diff time1, time2).to eql 3600
    end
    it 'gives correct result if time1 is greater than time2' do
      time1 = Time.now
      time2 = time1 - 1.hour
      expect(Hourglass::DateTimeCalculations.time_diff time1, time2).to eql 3600
    end
  end

  describe 'round_interval function' do
    round_minimum_in_seconds = 1800
    round_limits_in_seconds = 1620

    before :each do
      Hourglass::SettingsStorage[:round_minimum] = '0.5'
      Hourglass::SettingsStorage[:round_limit] = '90'
    end

    5.times do
      multiplied_minimum = rand(1..5) * round_minimum_in_seconds
      interval = rand(10...round_limits_in_seconds) + multiplied_minimum
      it "rounds down #{interval}" do
        expect(Hourglass::DateTimeCalculations.round_interval interval).to be multiplied_minimum
      end
    end

    5.times do
      multiplier = rand(1..5)
      interval = rand(round_limits_in_seconds + 10...round_minimum_in_seconds) + round_minimum_in_seconds * multiplier
      it "rounds up #{interval}" do
        expect(Hourglass::DateTimeCalculations.round_interval interval).to be round_minimum_in_seconds * (multiplier + 1)
      end
    end

    it 'does nothing if interval is on par with the minimum' do
      expect(Hourglass::DateTimeCalculations.round_interval round_minimum_in_seconds).to be round_minimum_in_seconds
    end
  end

  describe 'calculate stoppable time function' do

    before :each do
      Hourglass::SettingsStorage[:clamp_limit] = '12'
    end

    it 'gives correct result if time will not be clamped' do
      expect(Hourglass::DateTimeCalculations.calculate_stoppable_time 1.hour.ago).to be_between(Time.now - 1.minute, Time.now + 1.minute)
    end
    it 'gives correct result if time will be clamped' do
      expect(Hourglass::DateTimeCalculations.calculate_stoppable_time 13.hours.ago).to be_between(Time.now - 1.hour - 1.minute, Time.now - 1.hour + 1.minute)
    end
  end
end
