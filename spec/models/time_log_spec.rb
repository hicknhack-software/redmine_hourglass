require_relative '../spec_helper'
describe Chronos::TimeLog do

  before :all do
    Timecop.travel Time.new 2015, 2, 2, 15
  end

  it 'has a valid factory' do
    expect(build :time_log).to be_valid
  end

  it 'is invalid without a user' do
    expect(build :time_log, user: nil).not_to be_valid
  end

  it 'is invalid without a start time' do
    expect(build :time_log, start: nil).not_to be_valid
  end

  it 'is invalid without a stop time' do
    expect(build :time_log, stop: nil).not_to be_valid
  end

  it 'is invalid with start time greater than stop time' do
    expect(build :time_log, start: Time.now, stop: Time.now - 10.minutes).not_to be_valid
  end

  it 'is valid with no comment' do
    expect(build :timelog_with_comments, comments: nil).to be_valid
  end

  it 'is invalid with a comment greater' do
    expect(build :timelog_with_comments, comments: 'Hello!' * 43).not_to be_valid
  end

  describe 'booking' do
    let (:time_log) { create :time_log }
    let (:book!) { time_log.book booking_arguments }
    let (:booking_arguments) { {} }
    let (:hours) do
      start = booking_arguments[:start] || time_log.start
      stop = booking_arguments[:stop] || time_log.stop
      (stop - start) / 1.hour.to_f
    end

    context 'with no extra arguments' do
      it 'tries creating a time booking with the correct arguments' do
        expect(Chronos::TimeBooking).to receive(:create).with start: time_log.start, stop: time_log.stop, time_log_id: time_log.id, time_entry_arguments: {comments: time_log.comments, user_id: time_log.user_id, spent_on: Date.today, hours: hours}
        book!
      end
    end

    context 'with extra arguments project_id, issue_id and activity_id' do
      let (:booking_arguments) { {project_id: 1, issue_id: 2, activity_id: 3} }

      it 'tries creating a time booking with the correct arguments' do
        expect(Chronos::TimeBooking).to receive(:create).with start: time_log.start, stop: time_log.stop, time_log_id: time_log.id, time_entry_arguments: {project_id: booking_arguments[:project_id], issue_id: booking_arguments[:issue_id], comments: time_log.comments, activity_id: booking_arguments[:activity_id], user_id: time_log.user_id, spent_on: Date.today, hours: hours}
        book!
      end
    end
  end
end