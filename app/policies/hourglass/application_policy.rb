module Hourglass
  class ApplicationPolicy
    class Scope
      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        scope
      end
    end

    attr_reader :user, :record, :record_user, :project, :message

    def initialize(user, record)
      @user = user
      @record = record
      @record_user = record.user if record.respond_to? :user
      @project = record.project if record.respond_to? :project
    end

    def view?
      authorized? :view
    end

    def create?
      authorized? :create
    end

    def protected_parameters
      %i(start stop user user_id)
    end

    def change?(param = nil)
      authorized? protected_parameters.include?(param) ? :change_all : :change
    end

    def destroy?
      authorized? :destroy
    end

    alias_method :index?, :view?
    alias_method :show?, :view?
    alias_method :new?, :create?
    alias_method :edit?, :change?
    alias_method :update?, :change?

    private
    def authorized?(action)
      return foreign_authorized? action if record_user && record_user != user
      allowed_to? action
    end

    def foreign_authorized?(action)
      allowed_to? "#{action}_foreign"
    end

    def allowed_to?(action_args)
      action_args = {controller: "hourglass/#{controller_name}", action: action_args}
      project.blank? ? user.allowed_to_globally?(action_args) : user.allowed_to?(action_args, project)
    end

    def controller_name
      self.class.name.demodulize.gsub('Policy', '').tableize
    end
  end
end
