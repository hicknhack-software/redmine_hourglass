RSpec.shared_examples 'has a valid response' do
  run_test!

  after do |example|
    example.metadata[:response][:examples] = { 'application/json' => JSON.parse(response.body, symbolize_names: true) }
  end
end

RSpec.shared_examples 'error message' do |message, before_exec|
  response '400', message do
    schema '$ref': '#/definitions/error_msg'
    before &before_exec if before_exec

    run_test!

    it 'returns an error message' do
      data = JSON.parse(response.body, symbolize_names: true)
      expect(data[:message].length).to be >= 0
    end
  end
end

RSpec.shared_examples 'not found' do
  response '404', 'nothing found' do
    let(:id) { 'invalid' }
    run_test!
  end
end
