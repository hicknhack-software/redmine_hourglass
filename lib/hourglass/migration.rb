module Hourglass
  class Migration < (Rails::VERSION::MAJOR <= 4 ? ActiveRecord::Migration : ActiveRecord::Migration[4.2])
  end
end
