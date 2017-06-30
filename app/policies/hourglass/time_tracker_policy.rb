module Hourglass
  class TimeTrackerPolicy < ApplicationPolicy
    def start?
      authorized? :start
    end
  end
end
