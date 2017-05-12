def add_patch(module_to_patch, method: :include)
  patch = Chronos::RedminePatches.const_get "#{module_to_patch.name.demodulize}Patch"
  module_to_patch.send method, patch unless module_to_patch.ancestors.include? patch
end

ActionDispatch::Callbacks.to_prepare do
  [Project, TimeEntry, User].each {|module_to_patch| add_patch module_to_patch}
  [ProjectsHelper, SettingsController, Query].each {|module_to_patch| add_patch module_to_patch, method: :prepend}

  Redmine::Plugin.find(Chronos::PLUGIN_NAME).extend Chronos::RedminePatches::MirrorAssetsPatch
end

Chronos::RedmineHooks.load!
