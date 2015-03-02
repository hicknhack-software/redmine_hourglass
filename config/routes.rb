# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

scope 'chronos' do
  root to: 'chronos_overview#index'
  mount Chronos::Assets.instance, :at => 'assets'
end