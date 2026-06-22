# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::WebhookEndpoint do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:factory_webhook_endpoint) { build(:webhook_endpoint) }
  let(:response) do
    {
      'webhook_endpoint' => {
        'lago_id' => 'this-is-lago-id',
        'webhook_url' => 'https://foo.bar',
        'signature_algo' => 'hmac',
        'name' => 'My Webhook Endpoint',
        'event_types' => ['customer.created'],
        'created_at' => '2022-04-29T08:59:51Z',
      }
    }.to_json
  end
  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#create' do
    let(:params) { factory_webhook_endpoint.to_h }
    let(:body) do
      {
        'webhook_endpoint' => factory_webhook_endpoint.to_h,
      }
    end

    context 'when webhook endpoint is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/webhook_endpoints')
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns a webhook_endpoint' do
        webhook_endpoint = resource.create(params)

        expect(webhook_endpoint.lago_id).to eq('this-is-lago-id')
        expect(webhook_endpoint.webhook_url).to eq(factory_webhook_endpoint.webhook_url)
        expect(webhook_endpoint.signature_algo).to eq(factory_webhook_endpoint.signature_algo)
        expect(webhook_endpoint.name).to eq(factory_webhook_endpoint.name)
        expect(webhook_endpoint.event_types).to eq(factory_webhook_endpoint.event_types)
      end
    end

    context 'when webhook_endpoint failed to create' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/webhook_endpoints')
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#update' do
    let(:id) { 'id' }

    let(:body) do
      {
        'webhook_endpoint' => {
          webhook_url: 'https://foo.bar',
          signature_algo: 'hmac',
          name: 'My Webhook Endpoint',
          event_types: ['customer.created'],
        },
      }
    end

    let(:params) do
      {
        webhook_url: 'https://foo.bar',
        signature_algo: 'hmac',
        name: 'My Webhook Endpoint',
        event_types: ['customer.created'],
      }
    end

    context 'when webhook_endpoint is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/webhook_endpoints/#{id}")
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns a webhook_endpoint' do
        webhook_endpoint = resource.update(params, id)

        expect(webhook_endpoint.lago_id).to eq('this-is-lago-id')
        expect(webhook_endpoint.webhook_url).to eq(factory_webhook_endpoint.webhook_url)
        expect(webhook_endpoint.signature_algo).to eq(factory_webhook_endpoint.signature_algo)
        expect(webhook_endpoint.name).to eq(factory_webhook_endpoint.name)
        expect(webhook_endpoint.event_types).to eq(factory_webhook_endpoint.event_types)
      end
    end

    context 'when webhook_endpoint failed to update' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/webhook_endpoints/#{id}")
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, id) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get' do
    let(:id) { 'id' }

    context 'when webhook_endpoint is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/webhook_endpoints/#{id}")
          .to_return(body: response, status: 200)
      end

      it 'returns a webhook endpoint' do
        webhook_endpoint = resource.get(id)

        expect(webhook_endpoint.lago_id).to eq('this-is-lago-id')
        expect(webhook_endpoint.webhook_url).to eq(factory_webhook_endpoint.webhook_url)
        expect(webhook_endpoint.signature_algo).to eq(factory_webhook_endpoint.signature_algo)
        expect(webhook_endpoint.name).to eq(factory_webhook_endpoint.name)
        expect(webhook_endpoint.event_types).to eq(factory_webhook_endpoint.event_types)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/webhook_endpoints/#{id}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get(id) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#destroy' do
    let(:id) { 'id' }

    context 'when webhook endpoint is successfully deleted' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/webhook_endpoints/#{id}")
          .to_return(body: response, status: 200)
      end

      it 'returns a webhook endpoint' do
        webhook_endpoint = resource.destroy(id)

        expect(webhook_endpoint.lago_id).to eq('this-is-lago-id')
        expect(webhook_endpoint.webhook_url).to eq(factory_webhook_endpoint.webhook_url)
        expect(webhook_endpoint.signature_algo).to eq(factory_webhook_endpoint.signature_algo)
        expect(webhook_endpoint.name).to eq(factory_webhook_endpoint.name)
        expect(webhook_endpoint.event_types).to eq(factory_webhook_endpoint.event_types)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/webhook_endpoints/#{id}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy(id) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:response) do
      {
        'webhook_endpoints' => [
          {
            'lago_id' => 'this-is-lago-id',
            'webhook_url' => factory_webhook_endpoint.webhook_url,
            'signature_algo' => factory_webhook_endpoint.signature_algo,
            'name' => factory_webhook_endpoint.name,
            'event_types' => factory_webhook_endpoint.event_types,
            'created_at' => '2022-04-29T08:59:51Z',
          }
        ],
        'meta': {
          'current_page' => 1,
          'next_page' => 2,
          'prev_page' => nil,
          'total_pages' => 7,
          'total_count' => 63,
        }
      }.to_json
    end

    context 'when there is no options' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/webhook_endpoints')
          .to_return(body: response, status: 200)
      end

      it 'returns webhook endpoints on the first page' do
        response = resource.get_all

        expect(response['webhook_endpoints'].first['lago_id']).to eq('this-is-lago-id')
        expect(response['webhook_endpoints'].first['webhook_url']).to eq(factory_webhook_endpoint.webhook_url)
        expect(response['webhook_endpoints'].first['signature_algo']).to eq(factory_webhook_endpoint.signature_algo)
        expect(response['webhook_endpoints'].first['name']).to eq(factory_webhook_endpoint.name)
        expect(response['webhook_endpoints'].first['event_types']).to eq(factory_webhook_endpoint.event_types)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/webhook_endpoints')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
