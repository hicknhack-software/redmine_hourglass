require 'rake'

namespace :redmine do
  namespace :plugins do
    namespace :chronos do
      desc 'Import the database from the Redmine Time Tracker Plugin'
      task import_redmine_time_tracker: :environment do
        ChronosImport::RedmineTimeTracker.import!
      end
    end
  end
end
