# frozen_string_literal: true

require_relative './rails_helper'

RSpec.configure do |config|
  config.before :all, type: :request do
    Setting.rest_api_enabled = '1'
    freeze_time
  end

  config.after :all, type: :request do
    Setting.rest_api_enabled = '0'
  end

  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = File.join(Hourglass::PLUGIN_ROOT, 'swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.json' => {
      openapi: '3.0.1',
      info: {
        title: 'Hourglass API',
        description: 'This API allows you to do everything you can do in the Redmine Hourglass UI.',
        version: Hourglass::VERSION,
        'x-docsVersion' => Hourglass.swagger_docs_version
      },
      paths: {},
      servers: [
        { url: '/hourglass' }
      ],
      components: {
        securitySchemes: {
          api_key: {
            type: :apiKey,
            description: 'Available on the "my account" page in redmine',
            name: 'key',
            in: :query
          }
        },
        schemas: YAML.load_file(File.expand_path(File.dirname(__FILE__) + '/support/model_definitions.yml'))
      },
      security: [
        {api_key: []}
      ],
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :json
end
