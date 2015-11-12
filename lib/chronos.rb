ActiveSupport::Dependencies.autoload_paths << File.join(File.dirname(__FILE__), '..', 'app', 'models', 'concerns')
ActiveSupport::Dependencies.autoload_paths << File.join(File.dirname(__FILE__), 'chronos')

# load redmine patches
ActionDispatch::Callbacks.to_prepare do
  require_dependency 'redmine/plugin'
  require_dependency 'user'
  require_dependency 'project'
  require_dependency 'principal'
  require_dependency 'time_entry'

  unless Redmine::Plugin.included_modules.include? Chronos::RedminePatches::PluginPatch
    Redmine::Plugin.send :include, Chronos::RedminePatches::PluginPatch
  end

  unless Project.included_modules.include? Chronos::RedminePatches::ProjectPatch
    Project.send :include, Chronos::RedminePatches::ProjectPatch
  end

  unless TimeEntry.included_modules.include? Chronos::RedminePatches::TimeEntryPatch
    TimeEntry.send :include, Chronos::RedminePatches::TimeEntryPatch
  end

  unless User.included_modules.include? Chronos::RedminePatches::UserPatch
    User.send :include, Chronos::RedminePatches::UserPatch
  end
end

module Chronos
  def self.settings
    Setting.plugin_redmine_chronos
  end
end