require_relative '../spec_helper'
describe Hourglass::TimeBooking do

  before :all do
    travel_to Time.new 2015, 2, 2, 15
  end

  after :all do
    travel_back
  end

  before :each do
    Hourglass::SettingsStorage[:round_limit] = '50'
    Hourglass::SettingsStorage[:round_minimum] = '0.25'
  end

  it 'has a valid factory' do
    expect(build :time_booking).to be_valid
  end

  it 'deletes the associated time_entry if destroyed' do
    time_booking = create :time_booking
    time_entry_id = time_booking.time_entry.id
    time_booking.destroy
    expect(TimeEntry.find_by_id(time_entry_id)).to be_nil
  end

  it 'is invalid without a time entry' do
    expect(build :time_booking, time_entry: nil).not_to be_valid
  end

  it 'creates a valid time_entry if arguments are given and non is set' do
    time_log = create :time_log
    user = create :user
    time_booking = Hourglass::TimeBooking.create time_log_id: time_log.id, start: time_log.start, stop: time_log.stop, time_entry_attributes: {project: create(:project), activity: create(:time_entry_activity), user: user, author: user, spent_on: time_log.start, hours: Hourglass::DateTimeCalculations.time_diff_in_hours(time_log.start, time_log.stop)}
    expect(time_booking).to be_valid
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
