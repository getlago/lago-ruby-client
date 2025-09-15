# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Customers::Wallet do
  subject(:resource) { described_class.new(client, resource_id) }

  let(:client) { Lago::Api::Client.new }

  let(:resource_id) { 'customer_external_id' }
  let(:wallet_response) { load_fixture('wallet') }
  let(:wallet_id) { JSON.parse(wallet_response)['wallet']['lago_id'] }
  let(:tax) { create(:create_tax) }

  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#get_all' do
    let(:wallets_response) do
      {
        'wallets' => [JSON.parse(wallet_response)['wallet']],
        'meta': {
          'current_page' => 1,
          'next_page' => 2,
          'prev_page' => nil,
          'total_pages' => 7,
          'total_count' => 63,
        },
      }.to_json
    end

    context 'when there is no options' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{resource_id}/wallets")
          .to_return(body: wallets_response, status: 200)
      end

      it 'returns wallets on the first page' do
        response = resource.get_all

        expect(response['wallets'].first['lago_id']).to eq(wallet_id)
        expect(response['wallets'].first['status']).to eq('active')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{resource_id}/wallets?per_page=2&page=1")
          .to_return(body: wallets_response, status: 200)
      end

      it 'returns wallets on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['wallets'].first['lago_id']).to eq(wallet_id)
        expect(response['wallets'].first['status']).to eq('active')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{resource_id}/wallets")
          .to_return(body: error_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error(Lago::Api::HttpError)
      end
    end
  end
end
