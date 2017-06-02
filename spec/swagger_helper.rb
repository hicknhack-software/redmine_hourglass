require 'spec_helper'

AVAILABLE_PERMISSIONS = Redmine::AccessControl.permissions.select { |p| p.project_module == Hourglass::PLUGIN_NAME }.map &:name

def with_permission(permission)
  code = yield
  response code, "with #{permission} permission" do
    let(:user) { create :user, :as_member, permissions: [permission] }
    run_test!
  end
end

def test_permissions(*permissions)
  permissions.each do |permission|
    with_permission(permission) { '200' }
  end

  (AVAILABLE_PERMISSIONS - permissions).each do |permission|
    with_permission(permission) { '403' }
  end
end

def test_forbidden
  response '403', 'insufficient permissions' do
    let(:user) { create :user, :as_member }
    run_test!
  end
end

def test_unauthorized
  response '401', 'missing or wrong api key' do
    let(:key) { 'fake' }
    run_test!
  end
end

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
