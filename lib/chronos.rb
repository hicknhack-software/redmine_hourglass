JsRoutes.setup do |config|
  config.include = [
      /chronos/
  ]
  config.compact = true
  config.namespace = 'chronosRoutes'
end

module Chronos
  class << self
    def init
      set_autoload_paths
      add_redmine_patches
      Chronos::Assets.precompile += %w(application.js application.css global.js global.css jqplot.js jqplot/jquery.jqplot.css time_start.png time_stop.png)
      Chronos::RedmineHooks.load!
    end

    def settings
      Setting["plugin_#{plugin_name}"]
    end

    def plugin_name
      :redmine_chronos
    end

    private
    def set_autoload_paths
      [
          %w(.. app models concerns),
          %w(.. app controllers concerns),
          %w(chronos)
      ].each do |path|
        ActiveSupport::Dependencies.autoload_paths << File.join(File.dirname(__FILE__), *path)
      end
    end

    def add_redmine_patches
      ActionDispatch::Callbacks.to_prepare do
        [Project, TimeEntry, User].each do |module_to_patch|
          patch = Chronos::RedminePatches.const_get "#{module_to_patch.name.demodulize}Patch"
          module_to_patch.send :include, patch unless module_to_patch.included_modules.include? patch
        end

        Redmine::Plugin.find(Chronos.plugin_name).extend Chronos::RedminePatches::MirrorAssetsPatch
      end
    end
  end
end

Chronos.init
