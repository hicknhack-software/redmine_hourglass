module Hourglass
  module RedminePatches
    module TimeEntryActivityPatch
      extend ActiveSupport::Concern

      class_methods do
        def applicable(project = nil)
          project.present? ? project.activities : TimeEntryActivity.shared.active
        end
      end
    end
  end
end
