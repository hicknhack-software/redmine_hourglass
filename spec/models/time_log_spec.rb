require_relative '../spec_helper'
describe Chronos::TimeLog do

  before :all do
    Timecop.travel Time.new 2015, 2, 2, 15
  end

  before :each do
    Chronos.settings[:round_minimum] = '0.25'
    Chronos.settings[:round_limit] = '50'
    Chronos.settings[:round_carry_over_due] = '12'
  end

  it 'has a valid factory' do
    expect(build :time_log).to be_valid
  end

  it 'deletes the associated time booking if destroyed' do
    time_log = create :time_log
    time_booking = time_log.book project_id: create(:project).id, activity_id: create(:time_entry_activity).id
    expect(time_booking.persisted?).to be_truthy
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

  it 'is invalid when overlapping with another time log' do
    tl1 = create :time_log
    tl2 = build :time_log, user: tl1.user, start: tl1.stop - 5.minutes, stop: tl1.stop + 15.minutes
    expect(tl2).not_to be_valid
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
      Chronos::DateTimeCalculations.time_diff_in_hours(time_log.start, time_log.stop)
    end

    context 'with no extra arguments' do
      it 'tries creating a time booking with the correct arguments' do
        expect(time_log).to receive(:create_time_booking).with({start: time_log.start, stop: time_log.stop, time_log_id: time_log.id, time_entry_attributes: {comments: time_log.comments, user: time_log.user, spent_on: time_log.start.to_date, hours: hours}}.with_indifferent_access).and_return build :time_booking
        book!
      end
    end

    context 'with extra argument round' do
      let (:time_log) { create :time_log, start: Time.new(2015, 2, 13, 9), stop: Time.new(2015, 2, 13, 9, 13) }
      let (:booking_arguments) { {round: true} }

      it 'tries creating a time booking with the correct arguments(rounded stop)' do
        expect(time_log).to receive(:create_time_booking).with({start: time_log.start, stop: time_log.stop + 2.minutes, time_log_id: time_log.id, time_entry_attributes: {comments: time_log.comments, user: time_log.user, spent_on: time_log.start.to_date, hours: 0.25}}.with_indifferent_access).and_return build :time_booking
        book!
      end
    end

    context 'with extra arguments project_id, issue_id and activity_id' do
      let (:booking_arguments) { {project_id: create(:project).id, issue_id: 2, activity_id: 3} }

      it 'tries creating a time booking with the correct arguments(additional args)' do
        expect(time_log).to receive(:create_time_booking).with({start: time_log.start, stop: time_log.stop, time_log_id: time_log.id, time_entry_attributes: {project_id: booking_arguments[:project_id], issue_id: booking_arguments[:issue_id], comments: time_log.comments, activity_id: booking_arguments[:activity_id], user: time_log.user, spent_on: time_log.start.to_date, hours: hours}}.with_indifferent_access).and_return build :time_booking
        book!
      end
    end

    context 'with extra arguments start and stop' do
      let (:booking_arguments) { {start: time_log.start + 1.minutes, stop: time_log.stop - 1.minutes} }

      it 'tries creating a time booking with the correct arguments(ignores submitted start and stop)' do
        expect(time_log).to receive(:create_time_booking).with({start: time_log.start, stop: time_log.stop, time_log_id: time_log.id, time_entry_attributes: {comments: time_log.comments, user: time_log.user, spent_on: time_log.start.to_date, hours: hours}}.with_indifferent_access).and_return build :time_booking
        book!
      end
    end

    context 'with an existing time booking' do
      let (:booking_arguments) { {project_id: create(:project).id, activity_id: create(:time_entry_activity).id} }

      it 'throws the correct exception' do
        time_log.book booking_arguments
        expect { book! }.to raise_exception Chronos::AlreadyBookedException
      end
    end
  end

  describe 'updating' do
    let (:user) { create(:user) }
    let (:now) { Time.now.change(sec: 0) }

    it 'updates the time log' do
      time_log = create(:time_log, user: user, start: now, stop: now + 10.minutes)
      expect { time_log.update start: now - 5.minutes }.to change { time_log.reload.start - now }.from(0).to(-5.minutes)
    end

    it 'updates an associated time booking' do
      time_log = create(:time_log, user: user, start: now, stop: now + 10.minutes)
      time_booking = time_log.book project_id: create(:project).id, activity_id: create(:time_entry_activity).id
      expect { time_log.update start: now - 5.minutes }.to change { time_booking.reload.start - now }.from(0).to(-5.minutes)
    end

    it 'recalculates time bookings after its own time booking if rounding is given' do
      time_log = create(:time_log, user: user, start: now, stop: now + 10.minutes)
      time_log2 = create(:time_log, user: user, start: now + 10.minutes, stop: now + 20.minutes)
      project_id = create(:project).id
      activity_id = create(:time_entry_activity).id
      time_log.book project_id: project_id, activity_id: activity_id, round: true
      time_booking2 = time_log2.book project_id: project_id, activity_id: activity_id, round: true
      expect { time_log.update start: now - 5.minutes, round: true }.to change { time_booking2.reload.stop - now }.from(15.minutes).to(25.minutes)
    end
  end

  describe 'splitting' do
    let (:user) { create(:user) }
    let (:now) { Time.now.change(sec: 0) }

    it 'creates a new valid time log' do
      time_log = create(:time_log, user: user, start: now, stop: now + 10.minutes)
      time_log2 = time_log.split split_at: now + 5.minutes
      expect(time_log2).to be_valid
    end

    it 'sets the correctly start and stop times for the new time log' do
      time_log = create(:time_log, user: user, start: now, stop: now + 10.minutes)
      time_log2 = time_log.split split_at: now + 5.minutes
      expect([time_log2.start, time_log2.stop]).to eq [now + 5.minutes, now + 10.minutes]
    end

    it 'adjusts the stop time of the original time log' do
      time_log = create(:time_log, user: user, start: now, stop: now + 10.minutes)
      time_log.split split_at: now + 5.minutes
      expect(time_log.stop).to eq now + 5.minutes
    end

    it 'adjusts the booking of the original time log' do
      time_log = create(:time_log, user: user, start: now, stop: now + 10.minutes)
      time_booking = time_log.book project_id: create(:project).id, activity_id: create(:time_entry_activity).id
      expect { time_log.split split_at: now + 5.minutes }.to change { time_booking.reload.stop - now }.from(10.minutes).to(5.minutes)
    end

    it 'adjusts the booking of the original time log with rounding if given' do
      time_log = create(:time_log, user: user, start: now, stop: now + 10.minutes)
      time_booking = time_log.book project_id: create(:project).id, activity_id: create(:time_entry_activity).id, round: true
      expect { time_log.split split_at: now + 5.minutes, round: true }.to change { time_booking.reload.stop - now }.from(15.minutes).to(0)
    end

    it 'returns nothing if the split time is not in the time log' do
      time_log = create(:time_log, user: user, start: now, stop: now + 10.minutes)
      expect(time_log.split split_at: now + 15.minutes).to be_nil
    end
    context 'with insert new time log before old' do
      it 'sets the correctly start and stop times for the new time log' do
        time_log = create(:time_log, user: user, start: now, stop: now + 10.minutes)
        time_log2 = time_log.split split_at: now + 5.minutes, insert_new_before: true
        expect([time_log2.start, time_log2.stop]).to eq [now, now + 5.minutes]
      end

      it 'adjusts the stop time of the original time log' do
        time_log = create(:time_log, user: user, start: now, stop: now + 10.minutes)
        time_log.split split_at: now + 5.minutes, insert_new_before: true
        expect(time_log.start).to eq now + 5.minutes
      end
    end
  end

  describe 'combining' do
    let (:user) { create(:user) }
    let (:now) { Time.now.change(sec: 0) }

    it 'removes the time log which gets combined to the original' do
      time_log = create(:time_log, user: user, start: now, stop: now + 10.minutes)
      time_log2 = create(:time_log, user: user, start: now + 10.minutes, stop: now + 20.minutes)
      time_log.combine_with time_log2
      expect(time_log2.destroyed?).to be_truthy
    end

    it 'returns true if it successfully combined the 2 time logs' do
      time_log = create(:time_log, user: user, start: now, stop: now + 10.minutes)
      time_log2 = create(:time_log, user: user, start: now + 10.minutes, stop: now + 20.minutes)
      expect(time_log.combine_with time_log2).to be_truthy
    end

    it 'adjusts the stop time of the original' do
      time_log = create(:time_log, user: user, start: now, stop: now + 10.minutes)
      time_log2 = create(:time_log, user: user, start: now + 10.minutes, stop: now + 20.minutes)
      time_log.combine_with time_log2
      expect(time_log.stop).to eq now + 20.minutes
    end

    it 'returns false if the time logs start and stop time doesn\'t match' do
      time_log = create(:time_log, user: user, start: now, stop: now + 10.minutes)
      time_log2 = create(:time_log, user: user, start: now + 15.minutes, stop: now + 20.minutes)
      expect(time_log.combine_with time_log2).to be_falsey
    end

    it 'returns false if the time log has a time booking' do
      time_log = create(:time_log, user: user, start: now, stop: now + 10.minutes)
      time_log.book project_id: create(:project).id, activity_id: create(:time_entry_activity).id
      time_log2 = create(:time_log, user: user, start: now + 10.minutes, stop: now + 20.minutes)
      expect(time_log.combine_with time_log2).to be_falsey
    end
  end

  describe '"booking with rounding"-algorithm books correctly' do
    def create_time_logs(args)
      user = args[:user] || create(:user)
      result = []
      args[:entries].each do |entry|
        offset = entry[:offset] || 0
        start = (result.last && result.last.stop || args[:start]) + offset
        result.push create(:time_log, user: user, start: start, stop: start + entry[:length])
      end
      result
    end

    def book_all(time_logs, args)
      result = []
      time_logs.each do |time_log|
        result.push time_log.book args.dup
      end
      result
    end

    context 'without pauses' do
      it '6x 10 minutes' do
        now = Time.now.change(sec: 0)
        time_logs = create_time_logs start: now, entries: [
            {length: 10.minutes},
            {length: 10.minutes},
            {length: 10.minutes},
            {length: 10.minutes},
            {length: 10.minutes},
            {length: 10.minutes}
        ]
        time_bookings = book_all time_logs, project_id: create(:project).id, activity_id: create(:time_entry_activity).id, round: true
        expect(time_bookings.last.stop).to eq now + 1.hour
      end

      it 'different time values' do
        now = Time.now.change(sec: 0)
        time_logs = create_time_logs start: now, entries: [
            {length: 7.minutes},
            {length: 3.minutes},
            {length: 25.minutes},
            {length: 10.minutes},
            {length: 11.minutes},
            {length: 13.minutes}
        ]
        time_bookings = book_all time_logs, project_id: create(:project).id, activity_id: create(:time_entry_activity).id, round: true
        expect(time_bookings.last.stop).to eq now + 1.25.hours
      end
    end

    context 'with pauses smaller as configured overdue' do
      it '- 6x 10 minutes' do
        now = Time.now.change(sec: 0)
        time_logs = create_time_logs start: now, entries: [
            {length: 10.minutes},
            {length: 10.minutes},
            {length: 10.minutes, offset: 20.minutes},
            {length: 10.minutes},
            {length: 10.minutes, offset: 10.minutes},
            {length: 10.minutes}
        ]
        time_bookings = book_all time_logs, project_id: create(:project).id, activity_id: create(:time_entry_activity).id, round: true
        expect(time_bookings.last.stop).to eq now + 1.5.hours
      end

      it '- different time values' do
        now = Time.now.change(sec: 0)
        time_logs = create_time_logs start: now, entries: [
            {length: 7.minutes},
            {length: 3.minutes, offset: 20.minutes},
            {length: 25.minutes},
            {length: 10.minutes},
            {length: 11.minutes, offset: 10.minutes},
            {length: 13.minutes}
        ]
        time_bookings = book_all time_logs, project_id: create(:project).id, activity_id: create(:time_entry_activity).id, round: true
        expect(time_bookings.last.stop).to eq now + 1.75.hours
      end
    end

    context 'with pauses greater as configured overdue' do
      it '- 6x 10 minutes' do
        now = Time.now.change(sec: 0)
        time_logs = create_time_logs start: now, entries: [
            {length: 10.minutes},
            {length: 10.minutes},
            {length: 10.minutes, offset: 13.hours},
            {length: 10.minutes},
            {length: 10.minutes},
            {length: 10.minutes}
        ]
        time_bookings = book_all time_logs, project_id: create(:project).id, activity_id: create(:time_entry_activity).id, round: true
        expect(time_bookings.last.stop).to eq now + 14.hours + 5.minutes
      end

      it '- different time values' do
        now = Time.now.change(sec: 0)
        time_logs = create_time_logs start: now, entries: [
            {length: 7.minutes},
            {length: 3.minutes, offset: 15.hours},
            {length: 25.minutes},
            {length: 10.minutes},
            {length: 11.minutes, offset: 12.hours},
            {length: 13.minutes}
        ]
        time_bookings = book_all time_logs, project_id: create(:project).id, activity_id: create(:time_entry_activity).id, round: true
        expect(time_bookings.last.stop).to eq now + 28.25.hours
      end
    end

    context 'and updates existing bookings' do
      it '- 6x 10 minutes' do
        now = Time.now.change(sec: 0)
        project = create(:project)
        activity = create(:time_entry_activity)
        time_logs = create_time_logs start: now, entries: [
            {length: 10.minutes},
            {length: 10.minutes},
            {length: 10.minutes, offset: 10.minutes},
            {length: 10.minutes},
            {length: 10.minutes}
        ]
        time_bookings = book_all time_logs, project_id: project.id, activity_id: activity.id, round: true
        expect {
          second_time_log = time_logs[1]
          time_log = create(:time_log, user: second_time_log.user, start: second_time_log.stop, stop: second_time_log.stop + 10.minutes)
          time_log.book project_id: project.id, activity_id: activity.id, round: true
        }.to change { time_bookings.last.reload.stop - now }.from(55.minutes).to(1.hours)
      end

      it '- different time values' do
        now = Time.now.change(sec: 0)
        project = create(:project)
        activity = create(:time_entry_activity)
        time_logs = create_time_logs start: now, entries: [
            {length: 7.minutes},
            {length: 3.minutes},
            {length: 25.minutes},
            {length: 11.minutes, offset: 10.minutes},
            {length: 13.minutes}
        ]
        time_bookings = book_all time_logs, project_id: project.id, activity_id: activity.id, round: true
        expect {
          second_time_log = time_logs[2]
          time_log = create(:time_log, user: second_time_log.user, start: second_time_log.stop, stop: second_time_log.stop + 10.minutes)
          time_log.book project_id: project.id, activity_id: activity.id, round: true
        }.to change { time_bookings.last.reload.stop - now }.from(70.minutes).to(75.minutes)
      end
    end
  end
end
