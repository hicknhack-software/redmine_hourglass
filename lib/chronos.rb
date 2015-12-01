ActiveSupport::Dependencies.autoload_paths << File.join(File.dirname(__FILE__), '..', 'app', 'models', 'concerns')
ActiveSupport::Dependencies.autoload_paths << File.join(File.dirname(__FILE__), '..', 'app', 'controllers', 'concerns')
ActiveSupport::Dependencies.autoload_paths << File.join(File.dirname(__FILE__), 'chronos')

# load redmine patches
ActionDispatch::Callbacks.to_prepare do
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

JsRoutes.setup do |config|
  config.include = [
      /chronos/
  ]
  config.compact = true
  config.namespace = 'chronosRoutes'
end

module Chronos
  def self.settings
    Setting.plugin_redmine_chronos
  end
end
