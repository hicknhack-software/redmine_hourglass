require 'rspec/core/rake_task'

spec_path = File.join File.expand_path('../..', File.dirname(__FILE__)), 'spec'

namespace :redmine do
  namespace :plugins do
    namespace :hourglass do
      desc 'Import the database from the Redmine Time Tracker Plugin'
      task import_redmine_time_tracker: :environment do
        Hourglass::RedmineTimeTrackerImport.start!
      end

      desc 'Generate Swagger JSON files from the integration specs'
      RSpec::Core::RakeTask.new('api_docs') do |t|
        t.pattern = "#{spec_path}/integration/**/*_spec.rb"
        t.rspec_opts = ["-I#{spec_path}", '--format Rswag::Specs::SwaggerFormatter', '--order defined']
      end

      desc 'Run the specs'
      RSpec::Core::RakeTask.new(:spec) do |t|
        t.pattern = "#{spec_path}/**/*_spec.rb"
        t.rspec_opts = ["-I#{spec_path}"]
      end
    end
  end
end
