ActiveSupport::Dependencies.autoload_paths << File.join(File.dirname(__FILE__), '..', 'app', 'models', 'concerns')
ActiveSupport::Dependencies.autoload_paths << File.join(File.dirname(__FILE__), '..', 'app', 'controllers', 'concerns')
ActiveSupport::Dependencies.autoload_paths << File.join(File.dirname(__FILE__), 'chronos')

ActionDispatch::Callbacks.to_prepare do
  [Redmine::Plugin, Project, TimeEntry, User].each do |module_to_patch|
    patch = Chronos::RedminePatches.const_get "#{module_to_patch.name.demodulize}Patch"
    module_to_patch.send :include, patch unless module_to_patch.included_modules.include? patch
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
  class << self
    def settings
      Setting.plugin_redmine_chronos
    end
  end
end
