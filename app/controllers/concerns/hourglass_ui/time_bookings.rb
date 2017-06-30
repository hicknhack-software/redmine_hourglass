module HourglassUi
  module TimeBookings
    extend ActiveSupport::Concern

    included do
      menu_item :hourglass_time_bookings, only: :time_bookings
    end

    def time_bookings
      list_records Hourglass::TimeBooking
      build_chart_query
    end

    def new_time_bookings
      authorize Hourglass::TimeBooking, :create?
      now = Time.now.change(sec: 0)
      duration = Hourglass::DateTimeCalculations.in_hours Hourglass::DateTimeCalculations.round_minimum
      time_booking = Hourglass::TimeBooking.new start: now, stop: now + duration.hours,
                                                time_entry_attributes: {hours: duration}
      render 'hourglass_ui/time_bookings/new', locals: {time_booking: time_booking}, layout: false
    end

    def edit_time_bookings
      record_form Hourglass::TimeBooking
    end

    def bulk_edit_time_bookings
      bulk_record_form Hourglass::TimeBooking
    end

    def report
      @query_identifier = :time_bookings
      list_records Hourglass::TimeBooking
      @list_arguments[:entries] = @list_arguments[:entries].offset(nil).limit(nil)
      build_chart_query
      render layout: false
    end
  end
end
