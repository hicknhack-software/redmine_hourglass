module Hourglass
  class TimeLogPolicy < ApplicationPolicy
    def book?
      return false if record.booked?
      authorized? :book
    end
  end
end
