source 'https://rubygems.org'

# asset pipeline
gem 'uglifier'
gem 'coffee-script', '~> 2.4.1'
gem 'sassc-embedded', '~> 1.80.4'
gem 'sprockets', '~> 4.2.1'

# access control
gem 'pundit', '~> 2.5.0'

# this is useful for unix based systems which don't have a js runtime installed
# if you are on windows and this makes problems, simply remove the line
# gem 'therubyracer', :platform => :ruby

# views
gem 'slim', '~> 5.2.1'
gem 'js-routes', '~> 2.3.5'
# gem 'momentjs-rails', '>= 2.10.7'

gem 'rswag', '~> 2.16.0' # api docs
gem 'rspec-core'
gem 'rqrcode' unless dependencies.any? { |d| d.name == 'rqrcode' }

group :development, :test do
  gem 'rspec-rails', '~> 7.1.1'
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
