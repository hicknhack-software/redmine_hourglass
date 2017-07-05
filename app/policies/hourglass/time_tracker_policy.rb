module Hourglass
  class TimeTrackerPolicy < ApplicationPolicy
    class Scope < Scope
      def resolve
        return scope.all if foreign_authorized? :view
        super
      end
    end

    def create?
      return false if booking_parameters_forbidden?
      super
    end

    def update?
      return false if booking_parameters_forbidden?
      super
    end

    alias_method :start?, :create?
    alias_method :stop?, :create? # it's easy, if you are able to start it, you should be able to stop it

    private
    def booking_parameters_forbidden?
      booking_attributes? && !user.allowed_to?({controller: 'hourglass/time_logs', action: :book}, project)
    end

    def booking_parameters
      %i(project_id issue_id activity_id)
    end

    def booking_attributes?
      return false unless record.respond_to? :changed
      booking_attributes = record.changed.map(&:to_sym).select { |attr| booking_parameters.include? attr }
      booking_attributes.length > 0
    end
  end
end
