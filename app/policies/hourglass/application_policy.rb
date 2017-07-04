module Hourglass
  class ApplicationPolicy
    include RedmineAuthorization

    class Scope
      include RedmineAuthorization

      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        scope.where(user: user)
      end

      private
      def project
        nil
      end

      def record_user
        nil
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
      if unsafe_attributes?
        update_all_forbidden_message and return false unless authorized? :change_all
      end
      authorized? :create
    end

    def protected_parameters
      %i(start stop user user_id)
    end

    def change?(param = nil)
      condition = param ? protected_parameters.include?(param) : unsafe_attributes?
      if condition
        update_all_forbidden_message and return false unless authorized? :change_all
      end
      authorized? :change
    end

    def destroy?
      authorized? :destroy
    end

    alias_method :index?, :view?
    alias_method :show?, :view?
    alias_method :new?, :create?
    alias_method :bulk_create?, :create?
    alias_method :edit?, :change?
    alias_method :update?, :change?
    alias_method :bulk_update?, :change?
    alias_method :bulk_destroy?, :destroy?
  end
end
