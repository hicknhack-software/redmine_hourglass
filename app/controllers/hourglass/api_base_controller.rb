module Hourglass
  class ApiBaseController < ApplicationController
    include QueryConcern
    include SortConcern
    include BooleanParsing
    include DateTimeParsing
    around_action :catch_halt
    before_action :require_login

    before_action :parse_date_time

    rescue_from StandardError, with: :internal_server_error
    rescue_from ActionController::ParameterMissing, with: :missing_parameters
    rescue_from(ActiveRecord::RecordNotFound) { render_404 no_halt: true }
    rescue_from Query::StatementInvalid, with: :query_statement_invalid

    include ::AuthorizationConcern

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
      respond_with_error :forbidden, options[:message] || t('hourglass.api.errors.forbidden'), no_halt: options[:no_halt]
    end

    def render_404(options = {})
      respond_with_error :not_found, options[:message] || t("hourglass.api.#{controller_name}.errors.not_found", default: t('hourglass.api.errors.not_found')), no_halt: options[:no_halt]
    end

    def catch_halt
      catch :halt do
        yield
      end
    end

    def do_update(record, params_hash)
      record = authorize_update record, params_hash
      if record.errors.empty?
        respond_with_success
      else
        respond_with_error :bad_request, record.errors.full_messages, array_mode: :sentence
      end
    end

    def list_records(klass)
      authorize klass
      @query_identifier = klass.name.demodulize.tableize
      retrieve_query force_new: true
      init_sort
      scope = @query.results_scope order: sort_clause
      offset, limit = api_offset_and_limit
      respond_with_success(
          count: scope.count,
          offset: offset,
          limit: limit,
          records: scope.offset(offset).limit(limit).to_a
      )
    end

    def bulk(params_key = controller_name, &block)
      success = []
      errors = []
      params[params_key].each_with_index do |(id, params), index|
        id, params = "new#{index}", id if id.is_a?(Hash)
        is_new = id.start_with?('new')
        error_preface = "[#{t("hourglass.api.#{controller_name}.errors.bulk_#{'create_' if is_new}error_preface", id: is_new ? index : id)}:]"
        entry = bulk_entry id, params, &block
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
        flash_array :error, errors if errors.length > 0 && !api_request?
        respond_with_success success: success, errors: errors
      else
        respond_with_error :bad_request, errors
      end
    end

    def bulk_entry(id, params)
      yield id, params
    rescue ActiveRecord::RecordNotFound
      nil
    rescue Pundit::NotAuthorizedError => e
      e.policy.message || t('hourglass.api.errors.forbidden')
    end

    def missing_parameters(_e)
      respond_with_error :bad_request, t('hourglass.api.errors.missing_parameters'), no_halt: true
    end

    def internal_server_error(e)
      messages = [e.message] + e.backtrace
      Rails.logger.error messages.join("\n")
      respond_with_error :internal_server_error, Rails.env.production? ? t('hourglass.api.errors.internal_server_error') : messages, no_halt: true
    end

    def flash_array(type, messages)
      flash[type] = render_to_string partial: 'hourglass_ui/flash_array', locals: {messages: messages}
    end
  end
end
