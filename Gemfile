source 'https://rubygems.org'



# simulating assets pipeline
gem 'coffee-script'
gem 'sass'

gem 'slim'
gem 'strong_parameters'

group :test do
  gem 'zonebie'
  gem 'timecop'
  gem 'turn'
  gem 'faker'
  gem 'database_cleaner'
end

group :development do
  if RUBY_PLATFORM =~ /(win32|w32)/
    gem 'listen', '~> 2.7.5'
    gem 'wdm'
  end
  gem 'guard-rake'
  gem 'rb-readline'
  gem 'rubycritic', require: false
  gem 'rspec-rails', '~> 2.99'
  gem 'factory_girl_rails'
end
