module Chronos
  module ApplicationHelper
    def authorize_globally_for(controller, action)
      User.current.allowed_to_globally? controller: controller, action: action
    end
  end
end
