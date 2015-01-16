require 'redmine/i18n'
include Redmine::I18n
I18n.set_language_if_valid('de')

TimeBooking.delete_all
TimeEntry.delete_all

def book(tl, start_time, stop_time)
  round_limit = 0.5
  round_step = 15 * 60
  round_limit_in_sec = round_limit * round_step
  bookings = TimeBooking.overlaps_with(start_time, stop_time, round_limit_in_sec).joins(:time_entry).where(TimeEntry.arel_table[:user_id].eq(tl.user_id)).all
  latest_start = Time.at 0
  earliest_end = Time.now + 100.years #something in the far future as there is no properly working time infinity
  bookings.each do |booking|
    latest_start = booking.stopped_at if booking.stopped_at < stop_time + round_limit_in_sec && booking.stopped_at > latest_start
    earliest_end = booking.started_on if booking.started_on > start_time - round_limit_in_sec && booking.started_on < earliest_end
  end
  start_time, stop_time = Chronos::DateTimeCalculations.fit_in_bounds start_time, latest_start, stop_time, earliest_end, Chronos::DateTimeCalculations.round((stop_time - start_time).to_i)
  if stop_time > start_time
    tl.add_booking project_id: 1, activity_id: 10, started_on: start_time, stopped_at: stop_time
  end
end

TimeLog.where(user_id: 5).each do |tl|
  tb = book tl, tl.started_on, tl.stopped_at
  puts "#{tl.get_formatted_start_time} - #{tl.get_formatted_stop_time}: #{tl.get_formatted_time_span} min"
  puts "#{tb.get_formatted_start_time} - #{tb.get_formatted_stop_time}: #{tb.get_formatted_time} min" if tb.present?
end