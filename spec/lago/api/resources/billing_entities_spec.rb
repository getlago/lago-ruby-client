# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::BillingEntity do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:billing_entity_response) { load_fixture('billing_entity') }
  let(:billing_entity_code) { 'be_code' }

  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
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
