module Chronos
  class ApiBaseController < ApplicationController
    around_action :catch_halt
    rescue_from ArgumentError, with: :missing_halt_catch

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

    def render_error(args)
      args = {:message => args} unless args.is_a?(Hash)
      message = args[:message]
      message = l(message) if message.is_a?(Symbol)
      status = args[:status] || 500

      respond_to do |format|
        format.json {
          respond_with_error status, message
        }
      end
      super
    end

    def catch_halt
      catch :halt do
        yield
      end
    end

    def missing_halt_catch(e)
      unless e.message.include? ':halt'
        raise e
      end
    end

    # to use this, the controller need to implement a parameter_permission_map method like this:
    # def parameter_permission_map
    #   {
    #       time_tracker: {
    #           start: {
    #               permission: {
    #                   action: {
    #                       controller: params[:controller],
    #                       action: 'change_start'
    #                   },
    #                   options: {
    #                       global: true
    #                   }
    #               },
    #               error_message: I18n.t('chronos.api.time_trackers.errors.not_allowed_to_change_start')
    #           }
    #       }
    #   }
    # end
    def authorize_parameters
      messages = check_parameter_permissions params, parameter_permission_map
      respond_with_error :forbidden, messages unless messages.empty?
    end

    def check_parameter_permissions(params, permission_map)
      messages = []
      permission_map.each do |key, args|
        next unless params[key]
        permission_args = args[:permission]
        unless permission_args
          messages += check_parameter_permissions params[key], args
          next
        end

        unless User.current.allowed_to? *permission_args.values_at(:action, :context, :options)
          messages.push args[:error_message] || I18n.t('chronos.api.errors.forbidden_parameters', param: key.to_s)
        end
      end
      messages
    end

    def authorize_foreign
      unless @request_resource.user == User.current || User.current.allowed_to?({controller: params[:controller], action: 'process_foreign'}, @project, {global: true})
        respond_with_error :forbidden, I18n.t("chronos.api.#{params[:controller].split('/')[1]}.errors.change_others_forbidden")
      end
    end
  end
end
