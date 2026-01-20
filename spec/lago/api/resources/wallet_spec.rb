# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Wallet do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:factory_wallet) { build(:wallet) }
  let(:response) do
    {
      'wallet' => {
        'lago_id' => 'this-is-lago-id',
        'lago_customer_id' => factory_wallet.id,
        'name' => factory_wallet.name,
        'expiration_at' => factory_wallet.expiration_at,
        'balance_cents' => 10_000,
        'rate_amount' => factory_wallet.rate_amount,
        'created_at' => '2022-04-29T08:59:51Z',
        'recurring_transaction_rules' => factory_wallet.recurring_transaction_rules,
        'applies_to' => factory_wallet.applies_to,
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
    let(:params) do
      factory_wallet.to_h.merge(
        transaction_name: 'wallet transaction name',
        transaction_metadata: [{ 'key' => 'key', 'value' => 'value' }]
      )
    end
    let(:body) do
      {
        'wallet' => {
          'external_customer_id' => '12345',
          'rate_amount' => '1',
          'name' => 'wallet name',
          'paid_credits' => '100',
          'granted_credits' => '100',
          'expiration_at' => '2022-07-07T23:59:59Z',
          'transaction_name' => 'wallet transaction name',
          'transaction_metadata' => [{ 'key' => 'key', 'value' => 'value' }],
          'recurring_transaction_rules' => [
            {
              'paid_credits' => '105',
              'granted_credits' => '105',
              'threshold_credits' => '0',
              'trigger' => 'interval',
              'interval' => 'monthly',
              'method' => 'fixed',
              'started_at' => nil,
              'expiration_at' => '2026-12-31T23:59:59Z',
              'transaction_name' => 'Recurring Transaction Rule'
            }
          ],
          'applies_to' => { 'fee_types' => ['charge'], 'billable_metric_codes' => ['bm1'] }
        }
      }
    end

    context 'when wallet is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/wallets')
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns an wallet' do
        wallet = resource.create(params)

        expect(wallet.lago_id).to eq('this-is-lago-id')
        expect(wallet.name).to eq(factory_wallet.name)
        expect(wallet.expiration_at).to eq(factory_wallet.expiration_at)
        expect(wallet.recurring_transaction_rules.first.trigger).to eq('interval')
        expect(wallet.recurring_transaction_rules.first.interval).to eq('monthly')
        expect(wallet.recurring_transaction_rules.first.transaction_name).to eq('Recurring Transaction Rule')
        expect(wallet.recurring_transaction_rules.first.expiration_at).to eq(
          factory_wallet.recurring_transaction_rules.first[:expiration_at]
        )
        expect(wallet.applies_to.fee_types).to eq(factory_wallet.applies_to[:fee_types])
        expect(wallet.applies_to.billable_metric_codes).to eq(factory_wallet.applies_to[:billable_metric_codes])
      end
    end

    context 'when wallet failed to create' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/wallets')
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#update' do
    let(:params) { factory_wallet.to_h }
    let(:id) { 'id' }
    let(:body) do
      {
        'wallet' => {
          'external_customer_id' => '12345',
          'rate_amount' => '1',
          'name' => 'wallet name',
          'paid_credits' => '100',
          'granted_credits' => '100',
          'expiration_at' => '2022-07-07T23:59:59Z',
          'recurring_transaction_rules' => [
            {
              'paid_credits' => '105',
              'granted_credits' => '105',
              'threshold_credits' => '0',
              'trigger' => 'interval',
              'interval' => 'monthly',
              'method' => 'fixed',
              'started_at' => nil,
              'expiration_at' => '2026-12-31T23:59:59Z',
              'transaction_name' => 'Recurring Transaction Rule'
            }
          ],
          'applies_to' => { 'fee_types' => ['charge'], 'billable_metric_codes' => ['bm1'] }
        }
      }
    end

    context 'when wallet is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/wallets/#{id}")
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns an wallet' do
        wallet = resource.update(params, id)

        expect(wallet.lago_id).to eq('this-is-lago-id')
        expect(wallet.name).to eq(factory_wallet.name)
      end
    end

    context 'when wallet failed to update' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/wallets/#{id}")
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

    context 'when wallet is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/wallets/#{id}")
          .to_return(body: response, status: 200)
      end

      it 'returns an wallet' do
        wallet = resource.get(id)

        expect(wallet.lago_id).to eq('this-is-lago-id')
        expect(wallet.name).to eq(factory_wallet.name)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/wallets/#{id}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get(id) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#destroy' do
    let(:id) { 'id' }

    context 'when wallet is successfully terminated' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/wallets/#{id}")
          .to_return(body: response, status: 200)
      end

      it 'returns an wallet' do
        wallet = resource.destroy(id)

        expect(wallet.lago_id).to eq('this-is-lago-id')
        expect(wallet.name).to eq(factory_wallet.name)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/wallets/#{id}")
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
        'wallets' => [
          {
            'lago_id' => 'this-is-lago-id',
            'external_customer_id' => factory_wallet.external_customer_id,
            'name' => factory_wallet.name,
            'expiration_at' => factory_wallet.expiration_at,
            'paid_credits' => factory_wallet.paid_credits,
            'granted_credits' => factory_wallet.granted_credits,
            'rate_amount' => factory_wallet.rate_amount,
            'created_at' => '2022-04-29T08:59:51Z',
            'recurring_transaction_rules' => factory_wallet.recurring_transaction_rules,
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
        stub_request(:get, 'https://api.getlago.com/api/v1/wallets')
          .to_return(body: response, status: 200)
      end

      it 'returns wallets on the first page' do
        response = resource.get_all

        expect(response['wallets'].first['lago_id']).to eq('this-is-lago-id')
        expect(response['wallets'].first['name']).to eq(factory_wallet.name)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/wallets?external_customer_id=123&per_page=2&page=1')
          .to_return(body: response, status: 200)
      end

      it 'returns wallets on selected page' do
        response = resource.get_all({ external_customer_id: '123', per_page: 2, page: 1 })

        expect(response['wallets'].first['lago_id']).to eq('this-is-lago-id')
        expect(response['wallets'].first['name']).to eq(factory_wallet.name)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/wallets')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#replace_metadata' do
    let(:wallet_id) { 'wallet-id-123' }
    let(:metadata) { { 'foo' => 'bar', 'baz' => 'qux' } }
    let(:metadata_response) { { metadata: metadata }.to_json }

    before do
      stub_request(:post, "https://api.getlago.com/api/v1/wallets/#{wallet_id}/metadata")
        .with(body: { metadata: metadata })
        .to_return(body: metadata_response, status: 200)
    end

    it 'returns metadata hash' do
      response = resource.replace_metadata(wallet_id, metadata)

      expect(response).to eq(metadata)
    end
  end

  describe '#merge_metadata' do
    let(:wallet_id) { 'wallet-id-123' }
    let(:metadata) { { 'foo' => 'qux' } }
    let(:metadata_response) { { metadata: metadata }.to_json }

    before do
      stub_request(:patch, "https://api.getlago.com/api/v1/wallets/#{wallet_id}/metadata")
        .with(body: { metadata: metadata })
        .to_return(body: metadata_response, status: 200)
    end

    it 'returns metadata hash' do
      response = resource.merge_metadata(wallet_id, metadata)

      expect(response).to eq(metadata)
    end
  end

  describe '#delete_all_metadata' do
    let(:wallet_id) { 'wallet-id-123' }
    let(:metadata_response) { { metadata: nil }.to_json }

    before do
      stub_request(:delete, "https://api.getlago.com/api/v1/wallets/#{wallet_id}/metadata")
        .to_return(body: metadata_response, status: 200)
    end

    it 'returns nil metadata' do
      response = resource.delete_all_metadata(wallet_id)

      expect(response).to be_nil
    end
  end

  describe '#delete_metadata_key' do
    let(:wallet_id) { 'wallet-id-123' }
    let(:key) { 'foo' }
    let(:remaining_metadata) { { 'baz' => 'qux' } }
    let(:metadata_response) { { metadata: remaining_metadata }.to_json }

    before do
      stub_request(:delete, "https://api.getlago.com/api/v1/wallets/#{wallet_id}/metadata/#{key}")
        .to_return(body: metadata_response, status: 200)
    end

    it 'returns remaining metadata hash' do
      response = resource.delete_metadata_key(wallet_id, key)

      expect(response).to eq(remaining_metadata)
    end
  end
end
