module HourglassUi
  module TimeBookings
    extend ActiveSupport::Concern

    included do
      menu_item :hourglass_time_bookings, only: :time_bookings
    end

    def time_bookings
      retrieve_query
      init_sort
      @list_arguments = list_arguments
      build_chart_query
    end

    def new_time_bookings
      now = Time.now.change(sec: 0)
      duration = Hourglass::DateTimeCalculations.in_hours Hourglass::DateTimeCalculations.round_minimum
      time_booking = Hourglass::TimeBooking.new start: now, stop: now + duration.hours,
                                                time_entry_attributes: {hours: duration}
      render 'hourglass_ui/time_bookings/new', locals: {time_booking: time_booking}, layout: false
    end

    def edit_time_bookings
      time_booking = get_time_booking
      authorize_foreign
      render 'hourglass_ui/time_bookings/edit', locals: {time_bookings: [time_booking]}, layout: false unless performed?
    end

    def bulk_edit_time_bookings
      time_bookings = params[:ids].map do |id|
        @request_resource = Hourglass::TimeBooking.find_by id: id
        next unless @request_resource && foreign_allowed_to?
        @request_resource
      end.compact
      render_404 if time_bookings.empty?
      render 'hourglass_ui/time_bookings/edit', locals: {time_bookings: time_bookings}, layout: false unless performed?
    end

    def report
      @query_identifier = :time_bookings
      retrieve_query
      init_sort
      @list_arguments = list_arguments
      @list_arguments[:entries] = @list_arguments[:entries].offset(nil).limit(nil)
      build_chart_query
      render layout: false
    end

    private
    def get_time_booking
      time_booking = Hourglass::TimeBooking.find_by id: params[:id]
      render_404 unless time_booking.present?
      @request_resource = time_booking
    end
  end
end
