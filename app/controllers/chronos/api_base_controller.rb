module Chronos
  class ApiBaseController < ApplicationController
    around_action :catch_halt

    rescue_from ActionController::ParameterMissing, with: :missing_parameters

    private
    # use only these codes:
    # :ok (200)
    # :not_modified (304)
    # :bad_request (400)
    # :unauthorized (401)
    # :forbidden (403)
    # :not_found (404)
    # :internal_server_error (500)
    def respond_with_error(status, message, args = {})
      error_message = message.is_a?(Array) ? message.to_sentence : message
      render json: {
                 message: error_message,
                 status: Rack::Utils.status_code(status)
             },
             status: status
      throw :halt unless args[:no_halt]
    end

    def respond_with_success(response_obj = nil)
      if response_obj
        render json: response_obj
      else
        head :no_content
      end
      throw :halt
    end

    def render_error(args)
      args = {:message => args} unless args.is_a?(Hash)
      message = args[:message]
      message = l(message) if message.is_a?(Symbol)
      status = args[:status] || 500

      respond_to do |format|
        format.json {
          respond_with_error status, message, no_halt: true
        }
        format.any { super args}
      end
    end

    def catch_halt
      catch :halt do
        yield
      end
    end

    def missing_parameters(e)
      respond_with_error :bad_request, t("chronos.api.errors.missing_parameters"), no_halt: true
    end

    def find_optional_project
      @project = @request_resource.project
    end

    def authorize_with_project_or_global
      @project.present? ? authorize : authorize_global
    end

    def authorize_global(*args)
      super *args
      @authorize_global = true
    end

    def authorize_foreign
      unless @request_resource.user == User.current || allowed_to?("#{params[:action]}_foreign")
        respond_with_error :forbidden, t("chronos.api.#{controller_name}.errors.change_others_forbidden")
      end
    end

    def authorize_update_time
      controller_params = params[controller_name.singularize]
      has_start_or_stop_parameter = controller_params && (controller_params.include?(:start) || controller_params.include?(:stop))
      if has_start_or_stop_parameter && !allowed_to?('update_time')
        respond_with_error :forbidden, t("chronos.api.#{controller_name}.errors.update_time_forbidden")
      end
    end

    def allowed_to?(action, controller = params[:controller])
      User.current.allowed_to?({controller: controller, action: action}, @project, {global: @authorize_global})
    end
  end
end
