module Hourglass
  class UiPolicy < Struct.new(:user, :ui)
    def view?
      Pundit.policy!(user, Hourglass::TimeTracker).start? ||
          Pundit.policy!(user, Hourglass::TimeBooking).view? ||
          Pundit.policy!(user, Hourglass::TimeLog).view?
    end
  end
end
