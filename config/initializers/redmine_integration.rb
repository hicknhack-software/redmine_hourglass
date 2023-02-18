def add_patch(module_to_patch, method: :include)
  patch = Hourglass::RedminePatches.const_get "#{module_to_patch.name.demodulize}Patch"
  module_to_patch.send method, patch unless module_to_patch.ancestors.include? patch
end

if Rails.version < "5"
  ActionDispatch::Callbacks
else
  ActiveSupport::Reloader
end

Rails.application.config.after_initialize do
  [Project, TimeEntry, User, UserPreference, TimeEntryActivity].each { |module_to_patch| add_patch module_to_patch }
  [ProjectsHelper, SettingsController].each { |module_to_patch| add_patch module_to_patch, method: (Rails.version < "5" ? :include : :prepend) }
  [Query].each { |module_to_patch| add_patch module_to_patch, method: :prepend }

  Redmine::Plugin.find(Hourglass::PLUGIN_NAME).extend Hourglass::RedminePatches::MirrorAssetsPatch
  #Hourglass::Assets.compile if Rails.env.production?
end

Hourglass::RedmineHooks.load!
