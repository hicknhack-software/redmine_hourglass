require 'rake'

namespace :redmine do
  namespace :plugins do
    namespace :chronos do
      desc 'Import the database from the Redmine Time Tracker Plugin'
      task import_redmine_time_tracker: :environment do
        unless Redmine::Plugin.all.any? {|plugin| plugin.id == :redmine_time_tracker}
          fail('Can\'t import your data from Redmine Time Tracker, the plugin is not installed.')
        end
      end
    end
  end
end
