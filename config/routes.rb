# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

scope 'chronos' do
  root to: 'chronos_overview#index'
end

unless Rails.env.production?
  mount Chronos::Assets.instance, :at => 'plugin_assets/redmine_chronos/stylesheets'
  mount Chronos::Assets.instance, :at => 'plugin_assets/redmine_chronos/javascripts'
end
