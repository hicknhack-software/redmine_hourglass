ActiveSupport::Dependencies.autoload_paths << File.join(File.dirname(__FILE__), '..', 'app', 'models', 'concerns')
ActiveSupport::Dependencies.autoload_paths << File.join(File.dirname(__FILE__), '..', 'app', 'controllers', 'concerns')
ActiveSupport::Dependencies.autoload_paths << File.join(File.dirname(__FILE__), 'chronos')

ActionDispatch::Callbacks.to_prepare do
  Chronos.patch_redmine!
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

    def modules_to_patch
      @modules_to_patch ||= [Redmine::Plugin, Project, TimeEntry, User]
    end

    def patch_redmine!
      modules_to_patch.each do |module_to_patch|
        patch = Chronos::RedminePatches.const_get "#{module_to_patch.name.demodulize}Patch"
        module_to_patch.send :include, patch unless module_to_patch.included_modules.include? patch
      end
    end
  end
end
