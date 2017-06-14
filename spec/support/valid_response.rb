RSpec.shared_examples 'has a valid response' do
  run_test!

  after do |example|
    example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
  end
end
