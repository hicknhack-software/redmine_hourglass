require_relative '../spec_helper'
describe Chronos::TimeLog do

  before :all do
    Timecop.travel Time.new 2015, 2, 2, 15
  end

  before :each do
    Chronos.settings[:round_minimum] = '0.25'
    Chronos.settings[:round_limit] = '50'
  end

  it 'has a valid factory' do
    expect(build :time_log).to be_valid
  end

  it 'deletes the associated time_entry if destroyed' do
    time_log = create :time_log
    time_booking = time_log.book project_id: create(:project).id, activity_id: 9
    expect(time_booking).to be_valid
    time_log.destroy
    expect(Chronos::TimeBooking.find_by_id(time_booking.id)).to be_nil
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
    expect(build :time_log_with_comments, comments: nil).to be_valid
  end

  it 'is invalid with a comment greater' do
    expect(build :time_log_with_comments, comments: 'Hello!' * 43).not_to be_valid
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
        expect(Chronos::TimeBooking).to receive(:create).with start: time_log.start, stop: time_log.stop, time_log_id: time_log.id, time_entry_arguments: {comments: time_log.comments, user_id: time_log.user_id, spent_on: time_log.start.to_date, hours: hours}
        book!
      end
    end

    context 'with extra argument round' do
      let (:time_log) { create :time_log, start: Time.new(2015, 2, 13, 9), stop: Time.new(2015, 2, 13, 9, 13)}
      let (:booking_arguments) { {round: true} }

      it 'tries creating a time booking with the correct arguments(rounded stop)' do
        expect(Chronos::TimeBooking).to receive(:create).with start: time_log.start, stop: time_log.stop + 2.minutes, time_log_id: time_log.id, time_entry_arguments: {comments: time_log.comments, user_id: time_log.user_id, spent_on: Time.new(2015, 2, 13).to_date, hours: 0.25}
        book!
      end
    end

    context 'with extra arguments project_id, issue_id and activity_id' do
      let (:booking_arguments) { {project_id: 1, issue_id: 2, activity_id: 3} }

      it 'tries creating a time booking with the correct arguments(additional args)' do
        expect(Chronos::TimeBooking).to receive(:create).with start: time_log.start, stop: time_log.stop, time_log_id: time_log.id, time_entry_arguments: {project_id: booking_arguments[:project_id], issue_id: booking_arguments[:issue_id], comments: time_log.comments, activity_id: booking_arguments[:activity_id], user_id: time_log.user_id, spent_on: time_log.start.to_date, hours: hours}
        book!
      end
    end

    context 'with extra arguments start and stop' do
      let (:booking_arguments) { {start: time_log.start + 1.minutes, stop: time_log.stop - 1.minutes} }

      it 'tries creating a time booking with the correct arguments(adjusted start and stop)' do
        expect(Chronos::TimeBooking).to receive(:create).with start: booking_arguments[:start], stop: booking_arguments[:stop], time_log_id: time_log.id, time_entry_arguments: {comments: time_log.comments, user_id: time_log.user_id, spent_on: booking_arguments[:start].to_date, hours: hours}
        book!
      end
    end

    context 'with existing records defined' do

      it 'tries creating a time booking with the correct arguments(moved start and stop)' do
        existing = create :time_booking, user: time_log.user, start: time_log.start - 15.minutes, stop: time_log.start + 15.minutes
        expect(Chronos::TimeBooking).to receive(:create).with start: existing.stop, stop: time_log.stop + 15.minutes, time_log_id: time_log.id, time_entry_arguments: {comments: time_log.comments, user_id: time_log.user_id, spent_on: existing.stop.to_date, hours: hours}
        book!
      end
    end
  end
end