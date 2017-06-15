def with_permission(permission)
  code = yield
  response code, "with #{permission} permission" do
    let(:user) { create :user, :as_member, permissions: [permission] }
    run_test!
  end
end

def test_permissions(*permissions, success_code: '200')
  permissions.each do |permission|
    with_permission(permission) { success_code }
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

RSpec.shared_examples 'access rights' do |*permissions, **opts|
  test_permissions *permissions, opts
  test_forbidden
  test_unauthorized
end
