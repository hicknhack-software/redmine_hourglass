module Hourglass
  class ApiBaseController < ApplicationController
    include ::AuthorizationConcern
    include BooleanParsing

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
    def respond_with_error(status, message, **options)
      render json: {
          message: message.is_a?(Array) && options[:array_mode] == :sentence ? message.to_sentence : message,
          status: Rack::Utils.status_code(status)
      },
             status: status
      throw :halt unless options[:no_halt]
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
      respond_with_error :forbidden, options[:message] || t('hourglass.api.errors.forbidden')
    end

    def render_404(options = {})
      respond_with_error :not_found, options[:message] || t("hourglass.api.#{controller_name}.errors.not_found", default: t('hourglass.api.errors.not_found'))
    end

    def catch_halt
      catch :halt do
        yield
      end
    end

    def bulk(params_key = controller_name)
      success = []
      errors = []
      params[params_key].each_with_index do |(id, params), index|
        id, params = "new#{index}", id if id.is_a?(Hash)
        is_new = id.start_with?('new')
        error_preface = "[#{t("hourglass.api.#{controller_name}.errors.bulk_#{'create_' if is_new}error_preface", id: is_new ? index : id)}:]"
        entry = yield id, params
        if entry
          if entry.is_a? String
            errors.push "#{error_preface} #{entry}"
          elsif entry.errors.empty?
            success.push entry
          else
            errors.push "#{error_preface} #{entry.errors.full_messages.to_sentence}"
          end
        else
          errors.push "#{error_preface} #{t("hourglass.api.#{controller_name}.errors.not_found")}"
        end
      end
      if success.length > 0
        flash[:error] = errors if errors.length > 0
        respond_with_success success: success, errors: errors
      else
        respond_with_error :bad_request, errors
      end
    end

    def missing_parameters(e)
      respond_with_error :bad_request, t('hourglass.api.errors.missing_parameters'), no_halt: true
    end

    def authorize_foreign
      super { render_403 message: foreign_forbidden_message }
    end

    def foreign_forbidden_message
      t("hourglass.api.#{controller_name}.errors.change_others_forbidden")
    end

    def authorize_update_time
      render_403 message: update_time_forbidden_message unless update_time_allowed? params[controller_name.singularize]
    end

    def update_time_allowed?(controller_params = params[controller_name.singularize])
      has_start_or_stop_parameter = controller_params && (controller_params.include?(:start) || controller_params.include?(:stop))
      !has_start_or_stop_parameter || allowed_to?('update_time')
    end

    def update_time_forbidden_message
      t("hourglass.api.#{controller_name}.errors.update_time_forbidden")
    end

    def authorize_book
      render_403 message: booking_forbidden_message unless book_allowed?
    end

    def book_allowed?
      allowed_to? 'book', 'hourglass/time_logs'
    end

    def booking_forbidden_message
      t("hourglass.api.#{controller_name}.errors.booking_forbidden")
    end
  end
end
