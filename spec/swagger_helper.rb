require 'spec_helper'

AVAILABLE_PERMISSIONS = Redmine::AccessControl.permissions.select { |p| p.project_module == Hourglass::PLUGIN_NAME }.map &:name

RSpec.configure do |config|
  config.before :all, type: :request do
    Setting.rest_api_enabled = '1'
  end

  config.after :all, type: :request do
    Setting.rest_api_enabled = '0'
  end

  config.swagger_root = File.join Hourglass::PLUGIN_ROOT, 'swagger'
  config.swagger_docs = {
      'v1/swagger.json' => {
          swagger: '2.0',
          info: {
              title: 'Hourglass API',
              description: 'This API allows you to do everything you can do in the UI.',
              version: Hourglass::VERSION,
              'x-docsVersion': Hourglass.swagger_docs_version
          },
          basePath: '/hourglass',
          securityDefinitions: {
              api_key: {
                  type: :apiKey,
                  description: 'Available on the "my account" page in redmine',
                  name: 'key',
                  in: :query
              }
          },
          security: [
              {api_key: []}
          ],
          definitions: YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/support/model_definitions.yml'))['definitions']
      }
  }
end
