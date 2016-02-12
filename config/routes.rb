# gui controllers can't be namespaced because redmine doesn't use link_to properly with a prepended '/'
scope :chronos, as: :chronos do
  scope :ui, as: :ui, controller: :chronos_ui do
    root action: :index
    get 'time_logs'
    get 'time_logs/:id/edit', action: :edit_time_logs, as: :edit_time_logs
    get 'time_logs/:id/book', action: :book_time_logs, as: :book_time_logs
    get 'time_bookings'
    get 'time_bookings/:id/edit', action: :edit_time_bookings, as: :edit_time_bookings
    get 'report'
    get 'time_trackers'
    get 'time_trackers/:id/edit', action: :edit_time_trackers, as: :edit_time_trackers
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
    post 'bulk_update', on: :collection
    post 'start', on: :collection
    delete 'stop', on: :member
  end
  resources :time_logs, except: [:new, :edit, :create] do
    collection do
      post 'bulk_update'
      post 'bulk_book'
    end
    member do
      post 'book'
      post 'split'
      post 'combine'
    end
  end
  resources :time_bookings, except: [:new, :edit, :create]
end

unless Rails.env.production?
  Chronos::Assets.asset_directories.each do |asset_dir|
    mount Chronos::Assets.instance, at: File.join(Chronos::Assets.assets_directory_path, asset_dir)
  end
end
