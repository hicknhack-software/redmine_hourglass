def with_permission(*permissions)
  code = yield
  response code, "with #{permissions.first} permission" do
    let(:user) { create :user, :as_member, permissions: permissions }
    run_test!
  end
end

def test_permissions(*permissions, success_code: '200', error_code: '403', extra_permission: nil)
  extra_permission = [extra_permission].flatten
  permissions.each do |permission|
    with_permission(permission, *extra_permission) { success_code }
  end

  (AVAILABLE_PERMISSIONS - permissions).each do |permission|
    with_permission(permission) do
      extra_permission.include?(permission) ? 403 : error_code
    end
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
  test_permissions *permissions, opts
  test_forbidden opts.slice :error_code
  test_unauthorized
end
