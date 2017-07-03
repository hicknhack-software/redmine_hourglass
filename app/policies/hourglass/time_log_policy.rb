module Hourglass
  class TimeLogPolicy < ApplicationPolicy
    def book?
      @message = I18n.t('hourglass.api.time_logs.errors.already_booked') and return false if record.respond_to?(:booked?) && record.booked?
      authorized? :book
    end
  end
end
