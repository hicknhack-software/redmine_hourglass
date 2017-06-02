require 'spec_helper'

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
              version: 'v1',
              'x-docsVersion': Hourglass::SWAGGER_DOCS_VERSION
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
          ]
      }
  }
end
