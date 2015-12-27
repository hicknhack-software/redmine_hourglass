require_relative '../spec_helper'
describe Chronos::TimeTracker do

  before :all do
    Timecop.travel Time.new 2015, 2, 2, 15
  end

  before :each do
    Chronos.settings[:round_minimum] = '0.25'
    Chronos.settings[:round_limit] = '50'
    User.current = create :user
  end

  it 'has a valid factory' do
    expect(build :time_tracker).to be_valid
  end

  it 'is valid with no comment' do
    expect(build :time_tracker_with_comments, comments: nil).to be_valid
  end

  it 'is invalid with a comment too big' do
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

    it 'will not be removed if the time_log is invalid' do
      create :time_log, start: Time.now - 10.minutes, stop: Time.now + 10.minutes, user: User.current
      time_tracker = Chronos::TimeTracker.start
      expect { time_tracker.stop }.not_to change { Chronos::TimeTracker.count }.from(1)
    end

    it 'does not create a time log if the time_booking is invalid' do
      time_tracker = Chronos::TimeTracker.start project: create(:project)
      expect { time_tracker.stop }.not_to change { Chronos::TimeLog.count }.from(0)
    end

    it 'will not be removed if the time_booking is invalid' do
      time_tracker = Chronos::TimeTracker.start project: create(:project)
      expect { time_tracker.stop }.not_to change { Chronos::TimeTracker.count }.from(1)
    end
  end
end
