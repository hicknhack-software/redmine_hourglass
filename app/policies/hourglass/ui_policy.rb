module Hourglass
  class UiPolicy < Struct.new(:user, :ui)

    attr_reader :record, :record_user, :project, :message

    def view?
      Pundit.policy!(user, Hourglass::TimeTracker).start? ||
          Pundit.policy!(user, Hourglass::TimeBooking).view? ||
          Pundit.policy!(user, Hourglass::TimeLog).view?
    end
  end
end
