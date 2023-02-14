$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/lib"

Redmine::Plugin.register Hourglass::PLUGIN_NAME do
  name 'Hourglass'
  description 'Track your time and book it on issues and projects'
  url 'http://github.com/hicknhack-software/redmine_hourglass'
  author 'HicknHack Software GmbH'
  author_url 'http://www.hicknhack-software.com'
  version Hourglass::VERSION

  requires_redmine version_or_higher: '5.0.0'

  settings default: Hourglass::SettingsStorage.defaults, :partial => "settings/#{Hourglass::PLUGIN_NAME}"

  project_module Hourglass::PLUGIN_NAME do
    def with_foreign(*permissions)
      permissions.map { |x| [x, "#{x}_foreign".to_sym] }.flatten
    end

    permission :hourglass_track_time,
               {
                   :'hourglass/time_trackers' => [:create, :change, :destroy, :view],
                   :'hourglass/time_logs' => [:change]
               },
               require: :loggedin

    permission :hourglass_view_tracked_time,
               {
                   :'hourglass/time_trackers' => with_foreign(:view),
                   :'hourglass/time_logs' => with_foreign(:view)
               }, require: :loggedin

    permission :hourglass_view_own_tracked_time,
               {
                   :'hourglass/time_trackers' => [:view],
                   :'hourglass/time_logs' => [:view]
               }, require: :loggedin

    permission :hourglass_edit_tracked_time,
               {
                   :'hourglass/time_trackers' => with_foreign(:change, :change_all, :destroy),
                   :'hourglass/time_logs' => with_foreign(:create, :change, :change_all, :destroy)
               }, require: :loggedin

    permission :hourglass_edit_own_tracked_time,
               {
                   :'hourglass/time_trackers' => [:change, :change_all, :destroy],
                   :'hourglass/time_logs' => [:create, :change, :change_all, :destroy]
               }, require: :loggedin

    permission :hourglass_book_time,
               {
                   :'hourglass/time_logs' => with_foreign(:book),
                   :'hourglass/time_bookings' => with_foreign(:change)
               }, require: :loggedin

    permission :hourglass_book_own_time,
               {
                   :'hourglass/time_logs' => [:book],
                   :'hourglass/time_bookings' => [:change]
               }, require: :loggedin

    permission :hourglass_view_booked_time,
               {
                   :'hourglass/time_bookings' => with_foreign(:view)
               }, require: :member

    permission :hourglass_view_own_booked_time,
               {
                   :'hourglass/time_bookings' => [:view]
               }, require: :loggedin

    permission :hourglass_edit_booked_time,
               {
                   :'hourglass/time_bookings' => with_foreign(:create, :change, :change_all, :destroy)
               }, require: :loggedin

    permission :hourglass_edit_own_booked_time,
               {
                   :'hourglass/time_bookings' => [:create, :change, :change_all, :destroy]
               }, require: :loggedin
  end

  def allowed_to_see_index?
    proc { Pundit.policy!(User.current, :'hourglass/ui').view? }
  end

  menu :top_menu, :hourglass_root, :hourglass_ui_root_path, caption: :'hourglass.ui.menu.main', if: allowed_to_see_index?
  menu :account_menu, :hourglass_quick, '#', caption: '', if: allowed_to_see_index?, before: :my_account

  Redmine::MenuManager.map :hourglass_menu do |menu|
    menu.push :hourglass_overview, :hourglass_ui_root_path, caption: :'hourglass.ui.menu.overview', if: proc { Pundit.policy!(User.current, :'hourglass/ui').view? }
    menu.push :hourglass_time_logs, :hourglass_ui_time_logs_path, caption: :'hourglass.ui.menu.time_logs', if: proc { Pundit.policy!(User.current, Hourglass::TimeLog).view? }
    menu.push :hourglass_time_bookings, :hourglass_ui_time_bookings_path, caption: :'hourglass.ui.menu.time_bookings', if: proc { Pundit.policy!(User.current, Hourglass::TimeBooking).view? }
    menu.push :hourglass_time_trackers, :hourglass_ui_time_trackers_path, caption: :'hourglass.ui.menu.time_trackers', if: proc { Pundit.policy!(User.current, Hourglass::TimeTracker).view? }
  end
end
ActiveSupport::Reloader.reload!
