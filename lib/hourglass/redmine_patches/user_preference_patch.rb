module Hourglass
  module RedminePatches
    module UserPreferencePatch
      extend ActiveSupport::Concern

      def default_activity
        self[:default_activity]
      end

      def default_activity=(value)
        self[:default_activity] = value
      end
    end
  end
end
