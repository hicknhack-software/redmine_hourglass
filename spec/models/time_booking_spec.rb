require_relative '../spec_helper'
describe Chronos::TimeBooking do

  before :all do
    Timecop.travel Time.new 2015, 2, 2, 15
  end

  before :each do
    Chronos.settings[:round_minimum] = '0.25'
    Chronos.settings[:round_limit] = '50'
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
    project = create(:project)
    time_booking = Chronos::TimeBooking.create time_log_id: time_log.id, start: time_log.start, stop: time_log.stop, time_entry_arguments: {project_id: project.id, activity_id: 9, user_id: create(:user).id, spent_on: time_log.start, hours: (time_log.stop - time_log.start)/ 1.hour.to_f}
    puts "Errors: #{time_booking.time_entry.errors.full_messages.join(', ')}"
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

  context 'overlaps_with' do
    before :each do
      start_time = Time.new 2015, 2, 16, 9
      5.times do
        stop_time = start_time + 30.minutes
        create :time_booking, start: start_time, stop: stop_time
        start_time = stop_time
      end
    end
    it 'gives the correct records without delta' do
      expect(Chronos::TimeBooking.overlaps_with(Time.new(2015, 2, 16, 9, 15), Time.new(2015, 2, 16, 9, 45)).count).to be 2
    end

    it 'gives the correct records with delta' do
      expect(Chronos::TimeBooking.overlaps_with(Time.new(2015, 2, 16, 9, 15), Time.new(2015, 2, 16, 9, 45), 30.minutes).count).to be 3
    end
  end
end