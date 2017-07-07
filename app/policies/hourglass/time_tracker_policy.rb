module Hourglass
  class TimeTrackerPolicy < ApplicationPolicy
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
      booking_attributes? && !allowed_to?(:book, :time_logs)
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
