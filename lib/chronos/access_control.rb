module Chronos
  module AccessControl
    class << self
      def permissions_from_action(action)
        action = "#{action[:controller]}/#{action[:action]}" if action.is_a? Hash
        Redmine::AccessControl.permissions.map { |p| p.name if p.actions.include? action }.compact
      end
    end
  end
end
