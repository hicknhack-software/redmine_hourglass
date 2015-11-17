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
end
