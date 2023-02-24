source 'https://rubygems.org'

# asset pipeline
gem 'uglifier'
gem 'coffee-script', '~> 2.4.1'
gem 'sass', '~> 3.5.1'
gem 'sprockets', '~> 3.7.2', require: 'sprockets/railtie'

# access control
gem 'pundit', '~> 1.1.0'

# this is useful for unix based systems which don't have a js runtime installed
# if you are on windows and this makes problems, simply remove the line
# gem 'therubyracer', :platform => :ruby

# views
gem 'slim', '~> 3.0.8'
gem 'js-routes', '~> 2.2.4'
gem 'momentjs-rails', '>= 2.10.7'

gem 'rswag', '~> 2.5.1' # api docs
gem 'rspec-core'
gem 'rqrcode' unless dependencies.any? { |d| d.name == 'rqrcode' }

group :development, :test do
  gem 'rspec-rails', '~> 5.1.2'
  gem 'factory_bot_rails'
  gem 'zonebie'
  gem 'database_cleaner'
  gem 'faker'
end

if RUBY_VERSION < "2.1"
  group :development, :test do
    gem 'rubycritic', '<2.9.0', require: false
  end
elsif RUBY_VERSION < "2.3"
  group :development, :test do
    gem 'rubycritic', '<4.0.0', require: false
  end
else
  group :development, :test do
    gem 'rubycritic', require: false
  end
end
