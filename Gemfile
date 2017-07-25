source 'https://rubygems.org'

#asset pipeline
gem 'uglifier'
gem 'coffee-script'
gem 'sass'

# access control
gem 'pundit'

# this is useful for unix based systems which don't have a js runtime installed
# if you are on windows and this makes problems, simply remove the line
gem 'therubyracer', :platform => :ruby

#views
gem 'slim'
gem 'js-routes', '~> 1.3'
gem 'momentjs-rails', '>= 2.10.7'

gem 'rswag' # api docs
gem 'rspec-core'

group :development, :test do
  gem 'rubycritic', require: false
  gem 'rspec-rails', '~> 3.5', '>= 3.5.2'
  gem 'factory_girl_rails'
  gem 'zonebie'
  gem 'timecop'
  gem 'faker', '1.7.3'
  gem 'database_cleaner'
end
