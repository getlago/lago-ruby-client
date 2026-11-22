# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::V2::Client do
  # HTTP contracts from the pinned OpenAPI bundle. This fixture is not loaded by the client.
  contracts = JSON.parse(File.read(File.expand_path('../../../fixtures/api/v2/operations.json', __dir__)))

  let(:client) { described_class.new(api_key: 'test-key', retry_on_rate_limit: false) }

  it 'identifies the specification used for the operation contracts' do
    expect(Lago::Api::V2::OPENAPI_REVISION).to eq(contracts.fetch('openapi_revision'))
    expect(contracts.fetch('operations').length).to eq(155)
  end

  contracts.fetch('operations').each do |operation|
    context operation.fetch('operation_id') do
      let(:identifiers) do
        operation.fetch('path').scan(/\{([^}]+)\}/).flatten.to_h { |name| [name, "#{name}-123"] }
      end
      let(:resource) do
        parent_ids = operation.fetch('parents').map { |name| identifiers.fetch(name) }
        client.public_send(operation.fetch('resource'), *parent_ids)
      end
      let(:body) { { 'name' => 'Example', 'description' => nil, 'enabled' => false } }
      let(:query) { operation.fetch('query', {}) }
      let(:record) { { 'lago_id' => 'id-123', 'deleted_at' => nil, 'precise_amount' => '123.4500000001' } }
      let(:response_body) do
        if operation.fetch('empty_response')
          ''
        elsif operation.fetch('collection')
          key = operation.fetch('response_collection')
          result = { key => [record] }
          result['meta'] = { 'next_cursor' => 'next', 'prev_cursor' => nil } unless operation['response_root']
          result.to_json
        else
          value = operation.fetch('response_array') ? [record] : record
          { operation.fetch('response_root') => value }.to_json
        end
      end
      let(:expected_body) do
        root = operation['request_root']
        (root ? { root => body } : body).to_json
      end
      let(:arguments) do
        operation.fetch('arguments').map do |argument|
          { 'body' => body, 'query' => query }.fetch(argument) { identifiers.fetch(argument) }
        end
      end

      it 'sends the documented HTTP request and decodes the response' do
        values = identifiers
        path = operation.fetch('path').gsub(/\{([^}]+)\}/) { values.fetch(Regexp.last_match(1)) }
        request = stub_request(operation.fetch('http').downcase.to_sym, "https://api.getlago.com/api/v2#{path}")
          .with(headers: { 'Authorization' => 'Bearer test-key', 'Content-Type' => 'application/json' })
        expected_query = query.transform_keys { |key| key.delete_suffix('[]') }
        request = request.with(query: expected_query) if operation.fetch('http') == 'GET'
        request = request.with(body: expected_body) if operation.fetch('arguments').include?('body')
        request = request.with(body: '') unless operation.fetch('arguments').include?('body')
        request.to_return(status: 200, body: response_body, headers: { 'X-Lago-Endpoint-Status' => 'beta' })

        result = resource.public_send(operation.fetch('action'), *arguments)

        if operation.fetch('empty_response')
          expect(result).to be_nil
        elsif operation.fetch('collection')
          expect(result[operation.fetch('response_collection')].first.lago_id).to eq('id-123')
        else
          value = operation.fetch('response_array') ? result.first : result
          expect(value.lago_id).to eq('id-123')
          expect(value.precise_amount).to eq('123.4500000001')
          expect(value.deleted_at).to be_nil
        end
        expect(request).to have_been_requested.once
      end
    end
  end
end
