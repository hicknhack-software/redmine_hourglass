# clear all arguments given to rspec to prevent them to be given to redmine minitest as well
ARGV.clear

if ENV['PATH_TO_REDMINE']
  require File.expand_path(ENV['PATH_TO_REDMINE'] + '/test/test_helper')
else
  require File.expand_path(File.dirname(__FILE__) + '/../../../test/test_helper')
end

# require hourglass
require File.expand_path File.dirname(__FILE__) + '/../lib/hourglass'

require 'rspec/rails'
require 'rake'
require 'factory_bot_rails'

FactoryBot.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryBot.reload

#ENV['ZONEBIE_TZ'] = 'Pacific/Pago_Pago' #possibility to set a specific timezone
Zonebie.set_random_timezone

Rails.application.load_tasks

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Hourglass::PLUGIN_ROOT.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # use FactoryBot for setting up test data
  config.include FactoryBot::Syntax::Methods

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
    Setting.clear_cache
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
