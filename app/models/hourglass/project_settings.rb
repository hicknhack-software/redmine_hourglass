module Hourglass
  class ProjectSettings
    include TypeParsing
    include ActiveModel::Model

    attr_accessor :round_sums_only,
                  :round_minimum,
                  :round_limit,
                  :round_default,
                  :round_carry_over_due

    validates :round_sums_only, inclusion: { in: ['true', 'false', true, false] }, allow_blank: true
    validates :round_minimum, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 24 }, allow_blank: true
    validates :round_limit, numericality: { only_integer: true, greater_than_or_equal_to: 0,
                                            less_than_or_equal_to: 100 }, allow_blank: true
    validates :round_default, inclusion: { in: ['true', 'false', true, false] }, allow_blank: true
    validates :round_carry_over_due, numericality: { greater_than_or_equal_to: 0,
                                                     less_than_or_equal_to: 24 }, allow_blank: true

    def initialize(project = nil)
      @project = project
      from_hash Hourglass::SettingsStorage.project(@project)
    end

    def self.load(project = nil)
      self.new project
    end

    def update(attributes)
      from_hash attributes
      if valid?
        resolve_types
        Hourglass::SettingsStorage[project: @project] = to_hash
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
    end

    def to_hash
      {
        round_sums_only: round_sums_only,
        round_minimum: round_minimum,
        round_limit: round_limit,
        round_default: round_default,
        round_carry_over_due: round_carry_over_due
      }
    end

    def resolve_types
      self.round_sums_only = parse_type :boolean, @round_sums_only
      self.round_minimum = parse_type :float, @round_minimum
      self.round_limit = parse_type :integer, @round_limit
      self.round_default = parse_type :boolean, @round_default
      self.round_carry_over_due = parse_type :float, @round_carry_over_due
    end
  end
end
