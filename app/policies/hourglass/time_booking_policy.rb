module Hourglass
  class TimeBookingPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        return scope.visible if foreign_authorized? :view
        scope.visible.joins(:user).where(users: {id: user.id})
      end
    end
  end
end
