require 'hourglass'

Redmine::Plugin.register Hourglass::PLUGIN_NAME do
  name 'Hourglass'
  description 'Track your time and book it on issues and projects'
  url 'http://github.com/hicknhack-software/redmine_hourglass'
  author 'HicknHack Software GmbH'
  author_url 'http://www.hicknhack-software.com'
  version Hourglass::VERSION

  requires_redmine version_or_higher: '3.0.0'

  settings default: Hourglass::Settings.defaults, :partial => "settings/#{Hourglass::PLUGIN_NAME}"

  project_module Hourglass::PLUGIN_NAME do
    def with_foreign(*permissions)
      permissions.map { |x| [x, "#{x}_foreign".to_sym] }.flatten
    end

    def with_bulk(*permissions)
      permissions.map { |x| [x, "bulk_#{x}".to_sym] }.flatten
    end

    permission :hourglass_track_time,
               {
                   :'hourglass/time_trackers' => [:start, *with_bulk(:update), :stop],
                   :'hourglass/time_logs' => [*with_bulk(:update), :split, :join],
                   :'hourglass_ui' => [:index, :time_trackers, *with_bulk(:edit_time_trackers, :edit_time_logs)]
               },
               require: :loggedin

    permission :hourglass_view_tracked_time,
               {
                   :'hourglass/time_trackers' => with_foreign(:index, :show),
                   :'hourglass/time_logs' => with_foreign(:index, :show),
                   :'hourglass_ui' => [:index, *with_foreign(:time_logs, :time_trackers)]
               }, require: :loggedin

    permission :hourglass_view_own_tracked_time,
               {
                   :'hourglass/time_trackers' => [:index, :show],
                   :'hourglass/time_logs' => [:index, :show],
                   :'hourglass_ui' => [:index, :time_logs, :time_trackers]
               }, require: :loggedin

    permission :hourglass_edit_tracked_time,
               {
                   :'hourglass/time_trackers' => with_foreign(*with_bulk(:update, :destroy), :update_all),
                   :'hourglass/time_logs' => with_foreign(*with_bulk(:create, :update, :destroy), :update_all, :split, :join),
                   :'hourglass_ui' => [*with_foreign(*with_bulk(:edit_time_logs, :edit_time_trackers)), :new_time_logs]
               }, require: :loggedin

    permission :hourglass_edit_own_tracked_time,
               {
                   :'hourglass/time_trackers' => [*with_bulk(:update, :destroy), :update_all],
                   :'hourglass/time_logs' => [*with_bulk(:create, :update, :destroy), :update_all, :split, :join],
                   :'hourglass_ui' => [*with_bulk(:edit_time_logs, :edit_time_trackers), :new_time_logs]
               }, require: :loggedin

    permission :hourglass_book_time,
               {
                   :'hourglass/time_logs' => with_foreign(*with_bulk(:book)),
                   :'hourglass/time_bookings' => with_foreign(*with_bulk(:update)),
                   :'hourglass_ui' => with_foreign(*with_bulk(:book_time_logs, :edit_time_bookings))
               }, require: :loggedin

    permission :hourglass_book_own_time,
               {
                   :'hourglass/time_logs' => with_bulk(:book),
                   :'hourglass/time_bookings' => with_bulk(:update),
                   :'hourglass_ui' => with_bulk(:book_time_logs, :edit_time_bookings)
               }, require: :loggedin

    permission :hourglass_view_booked_time,
               {
                   :'hourglass/time_bookings' => with_foreign(:index, :show),
                   :'hourglass_ui' => [:index, *with_foreign(:report, :time_bookings)]
               }, require: :member

    permission :hourglass_view_own_booked_time,
               {
                   :'hourglass/time_bookings' => [:index, :show],
                   :'hourglass_ui' => [:index, :report, :time_bookings]
               }, require: :loggedin

    permission :hourglass_edit_booked_time,
               {
                   :'hourglass/time_bookings' => with_foreign(*with_bulk(:create, :update, :destroy), :update_all),
                   :'hourglass_ui' => [*with_foreign(*with_bulk(:edit_time_bookings)), :new_time_bookings]
               }, require: :loggedin

    permission :hourglass_edit_own_booked_time,
               {
                   :'hourglass/time_bookings' => [*with_bulk(:create, :update, :destroy), :update_all],
                   :'hourglass_ui' => [*with_bulk(:edit_time_bookings), :new_time_bookings]
               }, require: :loggedin
  end

  def allowed_to_see_index?
    proc { User.current.allowed_to_globally? controller: 'hourglass_ui', action: 'index' }
  end

  menu :top_menu, :hourglass_root, :hourglass_ui_root_path, caption: :'hourglass.ui.menu.main', if: allowed_to_see_index?
  menu :account_menu, :hourglass_quick, '#', caption: '', if: allowed_to_see_index?, before: :my_account

  Redmine::MenuManager.map :hourglass_menu do |menu|
    menu.push :hourglass_overview, :hourglass_ui_root_path, caption: :'hourglass.ui.menu.overview', if: proc { User.current.allowed_to_globally? controller: 'hourglass_ui', action: 'index' }
    menu.push :hourglass_time_logs, :hourglass_ui_time_logs_path, caption: :'hourglass.ui.menu.time_logs', if: proc { User.current.allowed_to_globally? controller: 'hourglass_ui', action: 'time_logs' }
    menu.push :hourglass_time_bookings, :hourglass_ui_time_bookings_path, caption: :'hourglass.ui.menu.time_bookings', if: proc { User.current.allowed_to_globally? controller: 'hourglass_ui', action: 'time_bookings' }
    menu.push :hourglass_time_trackers, :hourglass_ui_time_trackers_path, caption: :'hourglass.ui.menu.time_trackers', if: proc { User.current.allowed_to_globally? controller: 'hourglass_ui', action: 'time_trackers' }
  end
end
