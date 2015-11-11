module Chronos
  class ApiBaseController < ApplicationController
    around_action :catch_halt

    private
    # use only these codes:
    # :ok (200)
    # :not_modified (304)
    # :bad_request (400)
    # :unauthorized (401)
    # :forbidden (403)
    # :not_found (404)
    # :internal_server_error (500)
    def respond_with_error(status, message)
      error_message = message.is_a?(Array) ? message.to_sentence : message
      render json: {
                 message: error_message,
                 status: Rack::Utils.status_code(status)
             },
             status: status
    end

    def respond_with_success(response_obj = nil)
      if response_obj
        render json: response_obj
      else
        head :ok
      end
    end

    #implementation for render, head and redirect to always end the controller action
    def render(*args)
      super
      throw :halt
    end

    def redirect(*args)
      super
      throw :halt
    end

    def head(*args)
      super
      throw :halt
    end

    def catch_halt
      catch :halt do
        yield
      end
    end
  end
end