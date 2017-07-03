module AuthorizationConcern
  extend ActiveSupport::Concern

  included do
    include Pundit

    rescue_from(Pundit::NotAuthorizedError) do |e|
      render_403 message: e.policy.message, no_halt: true
    end

    def pundit_user
      User.current
    end

    def authorize(record, query = nil)
      super
      record
    end

    def authorize_update(record, params)
      authorize record
      record.attributes = params
      authorize record
    end
  end
end
