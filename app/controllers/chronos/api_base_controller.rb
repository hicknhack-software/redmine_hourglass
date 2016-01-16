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

    def render_403(options = {})
      respond_with_error :forbidden, options[:message] || t('chronos.api.errors.forbidden')
    end

    def render_404(options = {})
      respond_with_error :not_found, options[:message] || t("chronos.api.#{controller_name}.errors.not_found", default: t('chronos.api.errors.not_found'))
    end

    def catch_halt
      catch :halt do
        yield
      end
    end

    def bulk_update(params_key)
      success = []
      errors = []
      params[params_key].each do |id, params|
        error_preface = "[#{t("chronos.api.#{controller_name}.errors.bulk_error_preface", id: id)}:]"
        entry = yield id, params
        if entry.present?
          if entry.persisted?
            success.push entry
          else
            errors.push "#{error_preface} #{entry.errors.full_messages.to_sentence}"
          end
        else
          errors.push "#{error_preface} #{t("chronos.api.#{controller_name}.errors.not_found")}"
        end
      end
      if success.length > 0
        flash[:error] = errors.to_sentence if errors > 0
        respond_with_success
      else
        respond_with_error :bad_request, errors
      end
    end

    def missing_parameters(e)
      respond_with_error :bad_request, t('chronos.api.errors.missing_parameters'), no_halt: true
    end

    def parse_boolean(keys, params = self.params)
      keys = [keys] if keys.is_a? Symbol
      keys.each do |key|
        params[key] = case params[key].class.name
                        when 'String'
                          params[key] == '1' || params[key] == 'true'
                        when 'Fixnum', 'Integer'
                          params[key] == 1
                        else
                          params[key]
                      end
      end
      params
    end

    def authorize_foreign
      super do
        render_403 message: t("chronos.api.#{controller_name}.errors.change_others_forbidden")
      end
    end

    def authorize_update_time
      controller_params = params[controller_name.singularize]
      has_start_or_stop_parameter = controller_params && (controller_params.include?(:start) || controller_params.include?(:stop))
      if has_start_or_stop_parameter && !allowed_to?('update_time')
        render_403 message: t("chronos.api.#{controller_name}.errors.update_time_forbidden")
      end
    end
  end
end
