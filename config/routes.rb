# gui routes can't be namespaced
scope :chronos, as: :chronos do
  root to: 'chronos_ui#index'
  scope :ui, as: :ui, controller: :chronos_ui do
    get 'time_logs'
    get 'time_logs/:id/edit', action: :edit_time_logs, as: :edit_time_logs
    get 'time_logs/:id/book', action: :book_time_logs, as: :book_time_logs
    get 'time_bookings'
    get 'time_bookings/:id/edit', action: :edit_time_bookings, as: :edit_time_bookings
    get 'report'
  end
  scope :completion, as: :completion, controller: :chronos_completion do
    get 'issues'
    get 'activities'
  end

  resources :queries, controller: :chronos_queries, except: [:show, :index]

  scope :import, as: :import, controller: :chronos_import do
    put 'redmine_time_tracker_plugin'
  end
end

resources :projects do
  nested do
    scope :chronos, as: :chronos do
      resources :queries, controller: :chronos_queries, only: [:new, :create]
    end
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
