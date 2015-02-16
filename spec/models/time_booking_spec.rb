require_relative '../spec_helper'
describe Chronos::TimeBooking do

  before :all do
    Timecop.travel Time.new 2015, 2, 2, 15
  end

  it 'has a valid factory' do
    expect(build :time_booking).to be_valid
  end

  it 'is invalid without a time entry' do
    expect(build :time_booking, time_entry: nil).not_to be_valid
  end

  it 'is invalid without a time log' do
    expect(build :time_booking, time_log: nil).not_to be_valid
  end

  it 'is invalid without a start time' do
    expect(build :time_booking, start: nil, time_log: create(:time_log), time_entry: create(:time_entry)).not_to be_valid
  end

  it 'is invalid without a stop time' do
    expect(build :time_booking, stop: nil, time_log: create(:time_log), time_entry: create(:time_entry)).not_to be_valid
  end

  it 'is invalid with start time greater than stop time' do
    expect(build :time_booking, start: Time.now, stop: Time.now - 10.minutes, time_log: create(:time_log), time_entry: create(:time_entry)).not_to be_valid
  end

end