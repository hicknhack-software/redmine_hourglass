require 'rspec/core/rake_task'

spec_path = File.join File.expand_path('../..',  File.dirname(__FILE__)), 'spec'

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

        # NOTE: rspec 2.x support
        if Rswag::Specs::RSPEC_VERSION > 2 && Rswag::Specs.config.swagger_dry_run
          t.rspec_opts = ["-I#{spec_path}", '--format Rswag::Specs::SwaggerFormatter', '--dry-run', '--order defined']
        else
          t.rspec_opts = ["-I#{spec_path}", '--format Rswag::Specs::SwaggerFormatter', '--order defined']
        end
      end
    end
  end
end
