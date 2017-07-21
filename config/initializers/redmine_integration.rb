def add_patch(module_to_patch, method: :include)
  patch = Hourglass::RedminePatches.const_get "#{module_to_patch.name.demodulize}Patch"
  module_to_patch.send method, patch unless module_to_patch.ancestors.include? patch
end

ActionDispatch::Callbacks.to_prepare do
  [Project, TimeEntry, User, ProjectsHelper, SettingsController, UserPreference, TimeEntryActivity].each { |module_to_patch| add_patch module_to_patch }
  [Query].each { |module_to_patch| add_patch module_to_patch, method: :prepend }

  Redmine::Plugin.find(Hourglass::PLUGIN_NAME).extend Hourglass::RedminePatches::MirrorAssetsPatch
end

Hourglass::RedmineHooks.load!
