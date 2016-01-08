module Chronos
  module RedminePatches
    module ProjectPatch
      extend ActiveSupport::Concern

      included do
        has_many :chronos_time_bookings, dependent: :delete_all, class_name: 'Chronos::TimeBooking'
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
