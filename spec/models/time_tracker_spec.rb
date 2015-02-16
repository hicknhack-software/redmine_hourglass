require_relative '../spec_helper'
describe Chronos::TimeBooking do

  before :all do
    Timecop.travel Time.new 2015, 2, 2, 15
    User.current = create :user
  end

  it 'has a valid factory' do
    expect(build :time_tracker).to be_valid
  end

  it 'is valid with no comment' do
    expect(build :time_tracker_with_comments, comments: nil).to be_valid
  end

  it 'is invalid with a comment greater' do
    expect(build :time_tracker_with_comments, comments: 'Hello!' * 43).not_to be_valid
  end

  context 'on stopping' do
    it 'tries creating a time_log' do
      time_tracker = Chronos::TimeTracker.start
      expect { time_tracker.stop }.to change { Chronos::TimeLog.count }.from(0).to(1)
    end

    it 'will be removed' do
      time_tracker = Chronos::TimeTracker.start
      expect { time_tracker.stop }.to change { Chronos::TimeTracker.count }.from(1).to(0)
    end
  end
end