require File.join File.dirname(__FILE__), 'lib', 'chronos.rb'

Redmine::Plugin.register :redmine_chronos do
  name 'Redmine Chronos plugin'
  description 'Control your time like the god you think you are'
  url 'https://github.com/hicknhack-software/redmine_chronos'
  author 'HicknHack Software GmbH'
  author_url 'http://www.hicknhack-software.com'
  version File.read File.join 'plugins', 'redmine_chronos', '.plugin_version'

  requires_redmine version_or_higher: '3.0.0'

  settings default: {
               round_minimum: '0.25',
               round_limit: '50',
               round_carry_over_due: '12',
               round_default: false
           }, :partial => 'settings/chronos'

  project_module :redmine_chronos do
    def with_foreign(array)
      array.map { |x| [x, "#{x}_foreign".to_sym] }.flatten
    end

    permission :chronos_track_time,
               {
                   :'chronos/time_trackers' => [:start, :update, :stop],
                   :'chronos/time_logs' => [:update, :split, :combine]
               },
               require: :loggedin

    permission :chronos_view_tracked_time,
               {
                   :'chronos/time_trackers' => with_foreign([:index, :show]),
                   :'chronos/time_logs' => with_foreign([:index, :show])
               }, require: :loggedin

    permission :chronos_view_own_tracked_time,
               {
                   :'chronos/time_trackers' => [:index, :show],
                   :'chronos/time_logs' => [:index, :show]
               }, require: :loggedin

    permission :chronos_edit_tracked_time,
               {
                   :'chronos/time_trackers' => with_foreign([:update, :update_time, :destroy]),
                   :'chronos/time_logs' => with_foreign([:update, :update_time, :split, :combine, :destroy])
               }, require: :loggedin

    permission :chronos_edit_own_tracked_time,
               {
                   :'chronos/time_trackers' => [:update, :update_time, :destroy],
                   :'chronos/time_logs' => [:update, :update_time, :split, :combine, :destroy]
               }, require: :loggedin

    permission :chronos_book_time,
               {
                   :'chronos/time_logs' => with_foreign([:book]),
                   :'chronos/time_bookings' => with_foreign([:update])
               }, require: :loggedin

    permission :chronos_book_own_time,
               {
                   :'chronos/time_logs' => [:book],
                   :'chronos/time_bookings' => [:update]
               }, require: :loggedin

    permission :chronos_view_booked_time,
               {
                   :'chronos/time_bookings' => with_foreign([:index, :show])
               }, require: :member

    permission :chronos_view_own_booked_time,
               {
                   :'chronos/time_bookings' => [:index, :show]
               }, require: :loggedin

    permission :chronos_edit_booked_time,
               {
                   :'chronos/time_bookings' => with_foreign([:update, :update_time, :destroy])
               }, require: :loggedin

    permission :chronos_edit_own_booked_time,
               {
                   :'chronos/time_bookings' => [:update, :update_time, :destroy]
               }, require: :loggedin
  end
end
