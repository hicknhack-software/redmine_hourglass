module Hourglass
  class SettingsValidation
    include ActiveModel::Model
    include TypeParsing

    attr_accessor :is_project_settings,
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
    validates :report_title, length: { maximum: 23 }, unless: :is_project_settings
    validates :report_logo_url, length: { maximum: 23 }, unless: :is_project_settings
    validates :report_logo_width, numericality: { only_integer: true }, unless: :is_project_settings

    def initialize(settings)
      from_hash settings
    end

    private
    def from_hash(settings)
      settings = parse_type :boolean, [:round_default, :round_sums_only, :global_tracker], settings
      settings = parse_type :float, [:round_minimum, :round_carry_over_due], settings
      settings = parse_type :integer, [:round_limit, :report_logo_width], settings
      self.round_sums_only = settings[:round_sums_only] || true
      self.round_minimum = settings[:round_minimum] || 0.25
      self.round_limit = settings[:round_limit] || 50
      self.round_default = settings[:round_default] || false
      self.round_carry_over_due = settings[:round_carry_over_due] || 12
      unless is_project_settings
        self.report_title = settings[:report_title] || 'Report'
        self.report_logo_url = settings[:report_logo_url] || ''
        self.report_logo_width = settings[:report_logo_width] || 150
        self.global_tracker = settings[:global_tracker] || true
      end
    end
  end
end
