# gui routes can't be namespaced
scope :chronos do
  root to: 'chronos_overview#index'
end

namespace :chronos do
  resources :time_trackers, except: [:new, :edit, :create] do
    collection do
      post 'start'
    end
    member do
      delete 'stop'
    end
  end
  resources :time_logs, except: [:new, :edit, :create] do
    member do
      post 'book'
      post 'split'
      post 'combine'
    end
  end
  resources :time_bookings, except: [:new, :edit, :create]
end

unless Rails.env.production?
  mount Chronos::Assets.instance, :at => 'plugin_assets/redmine_chronos/stylesheets'
  mount Chronos::Assets.instance, :at => 'plugin_assets/redmine_chronos/javascripts'
end
