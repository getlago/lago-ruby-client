# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::V2::WebhookEndpoint do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:factory_webhook_endpoint) { build(:webhook_endpoint, :standard_webhooks) }
  let(:lago_id) { 'b7ab2926-1de8-4428-9bcd-779314ac129b' }
  let(:base_url) { 'https://api.getlago.com/api/v2/webhook_endpoints' }
  let(:expands_query) { { 'expands[]' => 'signing_keys' } }
  let(:endpoint_attributes) do
    {
      'lago_id' => lago_id,
      'webhook_url' => 'https://foo.bar',
      'signature_algo' => 'standard_webhooks',
      'name' => 'My Webhook Endpoint',
      'event_types' => ['customer.created'],
      'created_at' => '2026-01-01T00:00:00Z',
    }
  end
  let(:signing_key) do
    {
      'lago_id' => 'sk-1',
      'secret_key' => 'whsec_ZmFrZS1zZWNyZXQtZm9yLXNwZWNzLW9ubHk=',
      'created_at' => '2026-01-01T00:00:00Z',
    }
  end
  let(:expanded_response) do
    { 'webhook_endpoint' => endpoint_attributes.merge('signing_keys' => [signing_key]) }.to_json
  end
  let(:response) { { 'webhook_endpoint' => endpoint_attributes }.to_json }
  let(:params) { factory_webhook_endpoint.to_h.merge(unknown: 'dropped') }
  let(:body) do
    {
      'webhook_endpoint' => {
        'webhook_url' => 'https://foo.bar',
        'signature_algo' => 'standard_webhooks',
        'name' => 'My Webhook Endpoint',
        'event_types' => ['customer.created'],
      },
    }
  end

  shared_examples 'an endpoint with signing keys' do
    it 'parses the signing keys' do
      expect(webhook_endpoint.lago_id).to eq(lago_id)
      expect(webhook_endpoint.signature_algo).to eq('standard_webhooks')
      expect(webhook_endpoint.signing_keys.size).to eq(1)
      expect(webhook_endpoint.signing_keys.first.lago_id).to eq('sk-1')
      expect(webhook_endpoint.signing_keys.first.secret_key).to eq('whsec_ZmFrZS1zZWNyZXQtZm9yLXNwZWNzLW9ubHk=')
      expect(webhook_endpoint.signing_keys.first.created_at).to eq('2026-01-01T00:00:00Z')
    end
  end

  shared_examples 'an endpoint without signing keys' do
    it 'parses the endpoint without signing keys' do
      expect(webhook_endpoint.lago_id).to eq(lago_id)
      expect(webhook_endpoint.webhook_url).to eq('https://foo.bar')
      expect(webhook_endpoint.signing_keys).to be_nil
    end
  end

  describe '#create' do
    context 'with expands' do
      subject(:webhook_endpoint) { resource.create(params, expands: ['signing_keys']) }

      before do
        stub_request(:post, base_url)
          .with(query: expands_query, body:)
          .to_return(body: expanded_response, status: 200)
      end

      it_behaves_like 'an endpoint with signing keys'
    end

    context 'without expands' do
      subject(:webhook_endpoint) { resource.create(params) }

      before do
        stub_request(:post, base_url)
          .with(body:)
          .to_return(body: response, status: 200)
      end

      it_behaves_like 'an endpoint without signing keys'
    end

    context 'with an empty expands list' do
      subject(:webhook_endpoint) { resource.create(params, expands: []) }

      before do
        stub_request(:post, base_url)
          .with(query: {}, body:)
          .to_return(body: response, status: 200)
      end

      it_behaves_like 'an endpoint without signing keys'
    end

    context 'with several expands' do
      subject(:webhook_endpoint) { resource.create(params, expands: %w[signing_keys other]) }

      before do
        stub_request(:post, "#{base_url}?expands%5B%5D=signing_keys&expands%5B%5D=other")
          .with(body:)
          .to_return(body: expanded_response, status: 200)
      end

      it_behaves_like 'an endpoint with signing keys'
    end

    context 'when the API returns a validation error' do
      let(:error_body) { { 'status' => 422, 'error' => 'Unprocessable Entity', 'code' => 'validation_errors' }.to_json }

      before do
        stub_request(:post, base_url)
          .with(body:)
          .to_return(body: error_body, status: 422)
      end

      it 'raises an HttpError with the status and body' do
        expect { resource.create(params) }.to raise_error(Lago::Api::HttpError) { |error|
          expect(error.error_code).to eq(422)
          expect(error.error_body).to eq(error_body)
        }
      end
    end
  end

  describe '#update' do
    context 'with expands' do
      subject(:webhook_endpoint) { resource.update(lago_id, params, expands: ['signing_keys']) }

      before do
        stub_request(:put, "#{base_url}/#{lago_id}")
          .with(query: expands_query, body:)
          .to_return(body: expanded_response, status: 200)
      end

      it_behaves_like 'an endpoint with signing keys'
    end

    context 'without expands' do
      subject(:webhook_endpoint) { resource.update(lago_id, params) }

      before do
        stub_request(:put, "#{base_url}/#{lago_id}")
          .with(body:)
          .to_return(body: response, status: 200)
      end

      it_behaves_like 'an endpoint without signing keys'
    end

    context 'when the lago_id has reserved characters' do
      subject(:webhook_endpoint) { resource.update('a/b c', params) }

      before do
        stub_request(:put, "#{base_url}/a%2Fb%20c")
          .with(body:)
          .to_return(body: response, status: 200)
      end

      it_behaves_like 'an endpoint without signing keys'
    end
  end

  describe '#get' do
    context 'with expands' do
      subject(:webhook_endpoint) { resource.get(lago_id, expands: ['signing_keys']) }

      before do
        stub_request(:get, "#{base_url}/#{lago_id}")
          .with(query: expands_query)
          .to_return(body: expanded_response, status: 200)
      end

      it_behaves_like 'an endpoint with signing keys'
    end

    context 'without expands' do
      subject(:webhook_endpoint) { resource.get(lago_id) }

      before do
        stub_request(:get, "#{base_url}/#{lago_id}")
          .with(query: {})
          .to_return(body: response, status: 200)
      end

      it_behaves_like 'an endpoint without signing keys'
    end

    context 'when api_url has a path prefix' do
      subject(:webhook_endpoint) { resource.get(lago_id) }

      let(:client) { Lago::Api::Client.new(api_url: 'https://example.com/lago/') }

      before do
        stub_request(:get, "https://example.com/lago/api/v2/webhook_endpoints/#{lago_id}")
          .to_return(body: response, status: 200)
      end

      it_behaves_like 'an endpoint without signing keys'
    end

    context 'when a read-only key asks for the signing keys' do
      let(:error_body) { { 'status' => 403, 'error' => 'Forbidden', 'code' => 'forbidden' }.to_json }

      before do
        stub_request(:get, "#{base_url}/#{lago_id}")
          .with(query: expands_query)
          .to_return(body: error_body, status: 403)
      end

      it 'raises an HttpError with the status and body' do
        expect { resource.get(lago_id, expands: ['signing_keys']) }.to raise_error(Lago::Api::HttpError) { |error|
          expect(error.error_code).to eq(403)
          expect(error.error_body).to eq(error_body)
          expect(error.uri).to eq(URI(base_url))
        }
      end
    end
  end

  describe '#destroy' do
    it 'is not implemented' do
      expect { resource.destroy(lago_id) }.to raise_error(NotImplementedError)
    end
  end

  describe '#get_all' do
    it 'is not implemented' do
      expect { resource.get_all }.to raise_error(NotImplementedError)
    end
  end
end
