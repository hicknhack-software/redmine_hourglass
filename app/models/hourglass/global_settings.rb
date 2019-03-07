module Hourglass
  class GlobalSettings
    include ActiveModel::Model

    attr_accessor :round_sums_only,
                  :round_minimum,
                  :round_limit,
                  :round_default,
                  :round_carry_over_due,
                  :report_title,
                  :report_logo_url,
                  :report_logo_width,
                  :global_tracker

    validates :round_sums_only, inclusion: { in: ['true', 'false', '1', '0', true, false] }
    validates :round_minimum, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 24 }
    validates :round_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0,
                                            less_than_or_equal_to: 100 }
    validates :round_default, inclusion: { in: ['true', 'false', '1', '0', true, false] }
    validates :round_carry_over_due, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 24 }
    validates :report_title, length: { maximum: 23 }, presence: true
    validates :report_logo_url, length: { maximum: 23 }
    validates :report_logo_width, numericality: { only_integer: true, greater_than_or_equal_to: 0,
                                                  less_than_or_equal_to: 9999 }
    validates :global_tracker, inclusion: { in: ['true', 'false', '1', '0', true, false] }

    def initialize
      from_hash Hourglass::SettingsStorage
    end

    def update(attributes)
      from_hash attributes
      if valid?
        resolve_types
        Hourglass::SettingsStorage[] = to_hash
      end
      valid?
    end

    private

    def from_hash(attributes)
      self.round_sums_only = attributes[:round_sums_only]
      self.round_minimum = attributes[:round_minimum]
      self.round_limit = attributes[:round_limit]
      self.round_default = attributes[:round_default]
      self.round_carry_over_due = attributes[:round_carry_over_due]
      self.report_title = attributes[:report_title]
      self.report_logo_url = attributes[:report_logo_url]
      self.report_logo_width = attributes[:report_logo_width]
      self.global_tracker = attributes[:global_tracker]
    end

    def to_hash
      {
        round_sums_only: round_sums_only, round_minimum: round_minimum, round_limit: round_limit,
        round_default: round_default, round_carry_over_due: round_carry_over_due, report_title: report_title,
        report_logo_url: report_logo_url, report_logo_width: report_logo_width, global_tracker: global_tracker
      }
    end

    def resolve_types
      self.round_sums_only = parse_type :boolean, @round_sums_only
      self.round_minimum = parse_type :float, @round_minimum
      self.round_limit = parse_type :integer, @round_limit
      self.round_default = parse_type :boolean, @round_default
      self.round_carry_over_due = parse_type :float, @round_carry_over_due
      self.report_logo_width = parse_type :integer, @report_logo_width
      self.global_tracker = parse_type :boolean, @global_tracker
    end

    def parse_type(type, attribute)
      case type
      when :boolean
        ActiveRecord::Type::Boolean.new.type_cast_from_user(attribute)
      when :integer
        ActiveRecord::Type::Integer.new.type_cast_from_user(attribute)
      when :float
        ActiveRecord::Type::Float.new.type_cast_from_user(attribute)
      end
    end
  end
end
