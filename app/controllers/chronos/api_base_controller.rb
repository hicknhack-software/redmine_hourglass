module Chronos
  class ApiBaseController < ApplicationController
    include ::AuthorizationConcern

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
  end
end
