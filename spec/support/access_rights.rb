def with_permission(permission)
  code = yield
  response code, "with #{permission} permission" do
    let(:user) { create :user, :as_member, permissions: [permission] }
    run_test!
  end
end

def test_permissions(*permissions, success_code: '200', error_code: '403')
  permissions.each do |permission|
    with_permission(permission) { success_code }
  end

  (AVAILABLE_PERMISSIONS - permissions).each do |permission|
    with_permission(permission) { error_code }
  end
end

def test_forbidden(error_code: '403')
  response error_code, 'insufficient permissions' do
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

RSpec.shared_examples 'access rights' do |*permissions, **opts|
  test_permissions *permissions, **opts
  test_forbidden **(opts.slice :error_code)
  test_unauthorized
end
