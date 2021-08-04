# gui controllers can't be namespaced because redmine doesn't use link_to properly with a prepended '/'
scope :hourglass, as: :hourglass do
  scope :ui, as: :ui, controller: :hourglass_ui do
    root action: :index
    get 'time_logs'
    get 'time_logs/new', action: :new_time_logs
    get 'time_logs/:id/edit', action: :edit_time_logs, as: :edit_time_logs
    get 'time_logs/edit', action: :bulk_edit_time_logs, as: :bulk_edit_time_logs
    get 'time_logs/:id/book', action: :book_time_logs, as: :book_time_logs
    get 'time_logs/book', action: :bulk_book_time_logs, as: :bulk_book_time_logs
    get 'time_bookings'
    get 'time_bookings/new', action: :new_time_bookings
    get 'time_bookings/:id/edit', action: :edit_time_bookings, as: :edit_time_bookings
    get 'time_bookings/edit', action: :bulk_edit_time_bookings, as: :bulk_edit_time_bookings
    get 'report'
    get 'time_trackers'
    get 'time_trackers/:id/edit', action: :edit_time_trackers, as: :edit_time_trackers
    get 'time_trackers/edit', action: :bulk_edit_time_trackers, as: :bulk_edit_time_trackers
    get 'context_menu'

    get 'api_docs'
  end

  scope :completion, as: :completion, controller: :hourglass_completion do
    get 'issues'
    get 'activities'
    get 'users'
  end

  resources :queries, controller: :hourglass_queries, except: [:show, :index]

  scope :import, as: :import, controller: :hourglass_import do
    put 'redmine_time_tracker_plugin'
  end
end

resources :projects, only: [] do
  member do
    scope :hourglass, as: :hourglass do
      post 'settings', controller: :hourglass_projects
    end
  end
  nested do
    scope :hourglass, as: :hourglass do
      resources :queries, controller: :hourglass_queries, only: [:new, :create]
    end
  end
end

namespace :hourglass do
  resources :time_trackers, except: [:new, :edit, :create] do
    collection do
      post 'bulk_update'
      delete 'bulk_destroy'
      post 'start'
      put 'add_hint'
    end
    delete 'stop', on: :member
  end
  resources :time_logs, except: [:new, :edit] do
    collection do
      post 'bulk_create'
      post 'bulk_update'
      delete 'bulk_destroy'
      post 'bulk_book'
      post 'join'
    end
    member do
      post 'book'
      post 'split'
    end
  end
  resources :time_bookings, except: [:new, :edit] do
    collection do
      post 'bulk_create'
      post 'bulk_update'
      delete 'bulk_destroy'
    end
  end

  mount Rswag::Api::Engine => '/api-docs'
end


mount Hourglass::Assets.instance, at: File.join(Hourglass::Assets.assets_directory_path) unless Rails.env.production?
