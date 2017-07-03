module HourglassUi
  module TimeLogs
    extend ActiveSupport::Concern

    included do
      menu_item :hourglass_time_logs, only: :time_logs
    end

    def time_logs
      list_records Hourglass::TimeLog
    end

    def new_time_logs
      authorize Hourglass::TimeLog, :create?
      now = Time.now.change(sec: 0)
      time_log = Hourglass::TimeLog.new start: now, stop: now + Hourglass::DateTimeCalculations.round_minimum
      render 'hourglass_ui/time_logs/new', locals: {time_log: time_log}, layout: false
    end

    def edit_time_logs
      record_form Hourglass::TimeLog
    end

    def bulk_edit_time_logs
      bulk_record_form Hourglass::TimeLog
    end

    def book_time_logs
      record_form Hourglass::TimeLog, action: :book?, template: :book
    end

    def bulk_book_time_logs
      bulk_record_form Hourglass::TimeLog, action: :book?, template: :book
    end
  end
end
