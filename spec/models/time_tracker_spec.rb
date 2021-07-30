require_relative '../spec_helper'
describe Hourglass::TimeTracker do

  before :each do
    Hourglass::SettingsStorage[:round_minimum] = '0.25'
    Hourglass::SettingsStorage[:round_limit] = '50'
    Hourglass::SettingsStorage[:clamp_limit] = '12'
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
      time_tracker = Hourglass::TimeTracker.start
      expect { time_tracker.stop }.to change { Hourglass::TimeLog.count }.from(0).to(1)
    end

    it 'will be removed' do
      time_tracker = Hourglass::TimeTracker.start
      expect { time_tracker.stop }.to change { Hourglass::TimeTracker.count }.from(1).to(0)
    end

    it 'will not be removed if the time_log is invalid' do
      create :time_log, start: Time.now - 10.minutes, stop: Time.now + 10.minutes, user: User.current
      time_tracker = Hourglass::TimeTracker.start
      expect { time_tracker.stop }.not_to change { Hourglass::TimeTracker.count }.from(1)
    end

    it 'does not create a time log if the time_booking is invalid' do
      time_tracker = Hourglass::TimeTracker.start project: create(:project)
      expect { time_tracker.stop }.not_to change { Hourglass::TimeLog.count }.from(0)
    end

    it 'will not be removed if the time_booking is invalid' do
      time_tracker = Hourglass::TimeTracker.start project: create(:project)
      expect { time_tracker.stop }.not_to change { Hourglass::TimeTracker.count }.from(1)
    end

    it 'will not be clamped if the time does not exceed the limit' do
      freeze_time do
        time_tracker = Hourglass::TimeTracker.start
        time_tracker.start = Time.now - 10.minutes
        expect { time_tracker.stop }.to change { Hourglass::TimeLog.count }.from(0).to(1)
        expect(Hourglass::TimeLog.first.stop).to eql Time.now.change(sec: 0) + 1.minute
      end
    end

    it 'will be clamped if the time does exceed the limit' do
      freeze_time do
        time_tracker = Hourglass::TimeTracker.start
        time_tracker.start = Time.now - 13.hours
        expect { time_tracker.stop }.to change { Hourglass::TimeLog.count }.from(0).to(1)
        expect(Hourglass::TimeLog.first.stop).to eql 1.hour.ago.change(sec: 0) + 1.minute
      end
    end
  end
end
