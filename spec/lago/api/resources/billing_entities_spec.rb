# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::BillingEntity do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:billing_entity_response) { load_fixture('billing_entity') }
  let(:billing_entity_id) { JSON.parse(billing_entity_response)['billing_entity']['lago_id'] }
  let(:billing_entity_code) { JSON.parse(billing_entity_response)['billing_entity']['code'] }

  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  let(:not_found_response) do
    {
      'status' => 404,
      'error' => 'Not Found',
      'code' => 'billing_entity_not_found',
    }
  end

  describe '#create' do
    let(:params) { create(:create_billing_entity).to_h }

    before do
      stub_request(:post, 'https://api.getlago.com/api/v1/billing_entities')
        .to_return(body: billing_entity_response, status: 200)
    end

    it 'returns a billing entity' do
      response = resource.create(params)

      expect(response.lago_id).to eq(billing_entity_id)
      expect(response.code).to eq(billing_entity_code)
    end

    context 'when billing entity failed to create' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/billing_entities')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get' do
    context 'when billing entity is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/billing_entities/#{billing_entity_code}")
          .to_return(body: billing_entity_response, status: 200)
      end

      it 'returns a billing entity' do
        billing_entity = resource.get(billing_entity_code)

        expect(billing_entity.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
        expect(billing_entity.name).to eq('Acme Corp')
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/billing_entities/#{billing_entity_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get(billing_entity_code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#update' do
    let(:params) { create(:update_billing_entity).to_h }

    context 'when billing entity is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/billing_entities/#{billing_entity_code}")
          .to_return(body: billing_entity_response, status: 200)
      end

      it 'returns a billing entity' do
        response = resource.update(params, billing_entity_code)

        expect(response.lago_id).to eq(billing_entity_id)
        expect(response.code).to eq(billing_entity_code)
      end
    end

    context 'when billing entity is NOT successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/billing_entities/#{billing_entity_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, billing_entity_code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:billing_entities_response) { load_fixture('billing_entity_index') }

    context 'when there is no options' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/billing_entities')
          .to_return(body: billing_entities_response, status: 200)
      end

      it 'returns billable metrics on the first page' do
        response = resource.get_all

        expect(response['billing_entities'].size).to eq(2)
        expect(response.billing_entities.first.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
        expect(response.billing_entities.first.name).to eq('Acme Corp')
        expect(response.billing_entities.last.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a91')
        expect(response.billing_entities.last.name).to eq('Acme Corp 2')
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/billing_entities')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
