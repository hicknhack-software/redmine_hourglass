module Hourglass
  class TimeTrackerPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        return scope.all if foreign_authorized? :view
        super
      end
    end

    alias_method :start?, :create?
    alias_method :stop?, :create? # it's easy, if you are able to start it, you should be able to stop it
  end
end
