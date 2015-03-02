# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

scope 'chronos' do
  root to: 'chronos_overview#index'
end

mount Chronos::Assets.instance, :at => 'plugin_assets/redmine_chronos'
