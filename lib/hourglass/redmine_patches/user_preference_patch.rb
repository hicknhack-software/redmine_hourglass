module Hourglass
  module RedminePatches
    module UserPreferencePatch

      extend ActiveSupport::Concern

      included do
        # Redmine >= 3.4 introduces "safe_attributes"
        self.try :safe_attributes, 'default_activity'
      end

      def default_activity
        self[:default_activity]
      end

      def default_activity=(value)
        self[:default_activity] = value
      end
    end
  end
end

unless UserPreference.included_modules.include?(Hourglass::RedminePatches::UserPreferencePatch)
  UserPreference.send(:include, Hourglass::RedminePatches::UserPreferencePatch)
end