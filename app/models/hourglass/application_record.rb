module Hourglass
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    def serializable_hash(options)
      super(options).select { |_, v| v }
    end
  end
end
