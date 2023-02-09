module Hourglass
  module RedminePatches
    module ProjectPatch
      extend ActiveSupport::Concern

      included do
        scope :allowed_to_one_of, lambda {|*args|
          options = args.extract_options!
          if args.first.is_a?(Symbol)
            user = User.current
            permissions = *args
          else
            user = args.shift
            permissions = *args
          end
          where Project.allowed_to_one_of_condition user, permissions, options
        }
      end

      class_methods do
        def allowed_to_one_of_condition(user, permissions, options={})
          statement_stuff = []
          permissions.each do |permission|
            statement_stuff << allowed_to_condition(user, permission, options)
          end
          statement_stuff.join(' OR ')
        end
      end
    end
  end
end

unless Project.included_modules.include?(Hourglass::RedminePatches::ProjectPatch)
  Project.send(:include, Hourglass::RedminePatches::ProjectPatch)
end