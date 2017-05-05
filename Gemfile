source 'https://rubygems.org'

#asset pipeline
gem 'uglifier'
gem 'coffee-script'
gem 'sass'

#views
gem 'slim'
gem 'js-routes', '~> 1.3'
gem 'momentjs-rails', '>= 2.10.7'

group :test do
  gem 'zonebie'
  gem 'timecop'
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
  gem 'rspec-rails', '~> 3.5', '>= 3.5.2'
  gem 'factory_girl_rails'
end
