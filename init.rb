require File.join File.dirname(__FILE__), 'lib', 'chronos.rb'

Redmine::Plugin.register :redmine_chronos do
  name 'Redmine Chronos plugin'
  description 'Control your time like the god you think you are'
  url 'https://github.com/hicknhack-software/redmine_chronos'
  author 'HicknHack Software GmbH'
  author_url 'http://www.hicknhack-software.com'
  version File.read File.join 'plugins', 'redmine_chronos', '.plugin_version'

  settings default: {
               round_minimum: '0.25',
               round_limit: '50',
               round_carry_over_due: '12',
               round_default: false
           }, :partial => 'settings/chronos'

  project_module :redmine_chronos do
    # controller actions noted as strings are fake, which means they aren't real actions in that controller but used
    # to control allowed parameters in the other actions
    permission :chronos_track_time, {
                                      :'chronos/time_trackers' => [:start, :update, :stop, 'change_start'],
                                      :'chronos/time_logs' => [:update, :split, :combine]
                                  },
               require: :loggedin
    permission :chronos_view_tracked_time, {
                                             :'chronos/time_trackers' => [:index, :show, 'process_foreign'],
                                             :'chronos/time_logs' => [:index, :show, 'process_foreign']
                                         }, require: :loggedin
    permission :chronos_view_own_tracked_time, {
                                                 :'chronos/time_trackers' => [:index, :show],
                                                 :'chronos/time_logs' => [:index, :show]
                                             }, require: :loggedin
    permission :chronos_edit_tracked_time, {}, require: :loggedin
    permission :chronos_edit_own_tracked_time, {}, require: :loggedin
    permission :chronos_book_time, {}, require: :loggedin
    permission :chronos_book_own_time, {}, require: :loggedin
    permission :chronos_view_booked_time, {}, require: :member
    permission :chronos_view_own_booked_time, {}, require: :loggedin
    permission :chronos_edit_booked_time, {}, require: :loggedin
    permission :chronos_edit_own_booked_time, {}, require: :loggedin
  end
end
