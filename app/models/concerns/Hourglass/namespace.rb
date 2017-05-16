module Hourglass::Namespace
  extend ActiveSupport::Concern

  included do
    self.table_name_prefix = 'hourglass_'
  end
end
