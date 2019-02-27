module Hourglass
  class SettingsValidation
    include ActiveModel::Model

    attr_accessor :global_settings,
                  :round_sums_only,
                  :round_minimum,
                  :round_limit,
                  :round_default,
                  :round_carry_over_due,
                  :report_title,
                  :report_logo_url,
                  :report_logo_width,
                  :global_tracker

    validates :round_minimum, numericality: true
    validates :round_limit, numericality: { only_integer: true }
    validates :round_carry_over_due, numericality: true
    validates :report_title, length: { maximum: 23 }, if: :global_settings
    validates :report_logo_url, length: { maximum: 23 }, if: :global_settings
    validates :report_logo_width, numericality: { only_integer: true }, if: :global_settings

    def initialize(settings)
      settings = parse_boolean [:round_default, :round_sums_only, :global_tracker], settings
      settings = parse_float [:round_minimum, :round_carry_over_due], settings
      settings = parse_int [:round_limit, :report_logo_width], settings
      parse_settings settings
    end

    private
    def parse_settings(settings)
      self.round_sums_only = settings[:round_sums_only] if settings.has_key? :round_sums_only
      self.round_minimum = settings[:round_minimum] if settings.has_key? :round_minimum
      self.round_limit = settings[:round_limit] if settings.has_key? :round_limit
      self.round_default = settings[:round_default] if settings.has_key? :round_default
      self.round_carry_over_due = settings[:round_carry_over_due] if settings.has_key? :round_carry_over_due
      self.report_title = settings[:report_title] if settings.has_key? :report_title
      self.report_logo_url = settings[:report_logo_url] if settings.has_key? :report_logo_url
      self.report_logo_width = settings[:report_logo_width] if settings.has_key? :report_logo_width
      self.global_tracker = settings[:global_tracker] if settings.has_key? :global_tracker
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

    def parse_float(keys, params = self.params)
      keys = [keys] if keys.is_a? Symbol
      keys.each do |key|
        params[key] = case params[key].class.name
                      when 'String', 'Fixnum', 'Integer'
                        params[key].to_f
                      else
                        params[key]
                      end
      end
      params
    end

    def parse_int(keys, params = self.params)
      keys = [keys] if keys.is_a? Symbol
      keys.each do |key|
        params[key] = case params[key].class.name
                      when 'String', 'Fixnum', 'Integer'
                        params[key].to_i
                      else
                        params[key]
                      end
      end
      params
    end
  end
end
