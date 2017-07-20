module Hourglass
  class TimeLogPolicy < ApplicationPolicy
    def book?
      @message = I18n.t('hourglass.api.time_logs.errors.already_booked') and return false if booked?
      booking_allowed?
    end

    def booking_allowed?
      authorized? :book
    end

    def destroy?
      @message = I18n.t('hourglass.api.time_logs.errors.delete_booked') and return false if booked?
      super
    end

    alias_method :bulk_book?, :book?
    alias_method :split?, :change?
    alias_method :join?, :change?

    private
    def booked?
      record.respond_to?(:booked?) && record.booked?
    end
  end
end
