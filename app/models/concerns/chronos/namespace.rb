module Chronos::Namespace
  extend ActiveSupport::Concern

  included do
    self.table_name_prefix = 'chronos_'
  end
end