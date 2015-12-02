module Chronos::IsoStartStop
  extend ActiveSupport::Concern

  included do
    def start_before_type_cast
      start.iso8601
    end if self.column_names.include? 'start'

    def stop_before_type_cast
      stop.iso8601
    end if self.column_names.include? 'stop'
  end
end
