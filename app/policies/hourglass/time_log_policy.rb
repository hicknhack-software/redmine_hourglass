module Hourglass
  class TimeLogPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        return scope.all if foreign_authorized? :view
        super
      end
    end

    def book?
      @message = I18n.t('hourglass.api.time_logs.errors.already_booked') and return false if record.respond_to?(:booked?) && record.booked?
      booking_allowed?
    end

    def booking_allowed?
      authorized? :book
    end

    alias_method :bulk_book?, :book?
    alias_method :split?, :change?
    alias_method :join?, :change?
  end
end
