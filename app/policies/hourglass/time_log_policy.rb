module Hourglass
  class TimeLogPolicy < ApplicationPolicy
    def book?
      return false if record.respond_to?(:booked?) && record.booked?
      authorized? :book
    end
  end
end
