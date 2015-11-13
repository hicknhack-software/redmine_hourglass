# gui routes can't be namespaced
scope :chronos do
  root to: 'chronos_overview#index'
end

namespace :chronos do
  resources :time_tracker, except: [:new, :edit, :create, :destroy] do
    collection do
      post 'start'
    end
    member do
      delete 'stop'
    end
  end
  resources :time_log, except: [:new, :edit, :create] do
    member do
      post 'book'
    end
  end
  resources :time_booking, except: [:new, :edit, :create]
end

unless Rails.env.production?
  mount Chronos::Assets.instance, :at => 'plugin_assets/redmine_chronos/stylesheets'
  mount Chronos::Assets.instance, :at => 'plugin_assets/redmine_chronos/javascripts'
end
