# gui routes can't be namespaced
scope :chronos, as: :chronos do
  root to: 'chronos_ui#index'
  get 'time_logs', to: 'chronos_ui#time_logs'
  get 'time_bookings', to: 'chronos_ui#time_bookings'
  scope :completion, as: :completion do
    get 'issues', to: 'chronos_completion#issues'
    get 'activities', to: 'chronos_completion#activities'
  end
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
