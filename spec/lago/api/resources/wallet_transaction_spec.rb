# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::WalletTransaction do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:factory_wallet_transaction) { build(:wallet_transaction) }
  let(:response) do
    {
      'wallet_transactions' => [
        {
          'lago_id' => 'this-is-lago-id',
          'lago_wallet_id' => factory_wallet_transaction.wallet_id,
          'amount' => factory_wallet_transaction.paid_credits,
          'name' => factory_wallet_transaction.name,
          'status' => 'pending',
          'transaction_status' => 'purchased',
          'transaction_type' => 'inbound',
          'credit_amount' => factory_wallet_transaction.paid_credits,
          'settled_at' => '2022-04-29T08:59:51Z',
          'created_at' => '2022-04-29T08:59:51Z'
        },
        {
          'lago_id' => 'this-is-lago-id2',
          'lago_wallet_id' => factory_wallet_transaction.wallet_id,
          'amount' => factory_wallet_transaction.granted_credits,
          'name' => factory_wallet_transaction.name,
          'status' => 'settled',
          'transaction_status' => 'purchased',
          'transaction_type' => 'inbound',
          'credit_amount' => factory_wallet_transaction.granted_credits,
          'settled_at' => '2022-04-29T08:59:51Z',
          'created_at' => '2022-04-29T08:59:51Z'
        }
      ]
    }
  end
  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record'
    }.to_json
  end

  describe '#create' do
    let(:params) do
      {
        wallet_id: "123",
        name: "Transaction Name",
        paid_credits: "100",
        granted_credits: "100",
        voided_credits: "0",
        extra_param: "extra_value"
      }
    end
    let(:body) do
      {
        'wallet_transaction' => {
          "wallet_id" => "123",
          "name" => "Transaction Name",
          "paid_credits" => "100",
          "granted_credits" => "100",
          "voided_credits" => "0"
        }
      }
    end

    context 'when wallet_transaction is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/wallet_transactions')
          .with(body: body)
          .to_return(body: response.to_json, status: 200)
      end

      it 'returns an wallet_transactions' do
        wallet_transactions = resource.create(params)

        expect(wallet_transactions.first.lago_id).to eq('this-is-lago-id')
        expect(wallet_transactions.last.lago_id).to eq('this-is-lago-id2')
        expect(wallet_transactions).to all(have_attributes(name: 'Transaction Name'))
      end
    end

    context 'when wallet_transaction failed to create' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/wallet_transactions')
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    before do
      response['meta'] = {
        'current_page' => 1,
        'next_page' => 2,
        'prev_page' => nil,
        'total_pages' => 7,
        'total_count' => 63,
      }

      stub_request(:get, "https://api.getlago.com/api/v1/wallets/555/wallet_transactions")
        .to_return(body: response.to_json, status: 200)
    end

    it 'returns a list of wallet transactions' do
      response = resource.get_all('555')

      expect(response['wallet_transactions'].first['lago_id']).to eq('this-is-lago-id')
      expect(response['meta']['current_page']).to eq(1)
    end
  end

  describe '#payment_url' do
    let(:wallet_transaction) { create(:wallet_transaction) }
    let(:wallet_transaction_id) { wallet_transaction.id }

    let(:url_response) do
      {
        'wallet_transaction_payment_details' => {
          'payment_url' => 'https://example.com',
        }
      }.to_json
    end

    before do
      stub_request(:post, "https://api.getlago.com/api/v1/wallet_transactions/#{wallet_transaction_id}/payment_url")
        .with(body: {})
        .to_return(body: url_response, status: 200)
    end

    it 'returns payment url' do
      result = resource.payment_url(wallet_transaction_id)

      expect(result.payment_url).to eq('https://example.com')
    end
  end

  describe '#consumptions' do
    let(:wallet_transaction_id) { 'inbound-transaction-id' }
    let(:consumptions_response) do
      {
        'wallet_transaction_consumptions' => [
          {
            'lago_id' => 'consumption-1',
            'amount_cents' => 500,
            'created_at' => '2024-01-15T10:00:00Z',
            'wallet_transaction' => {
              'lago_id' => 'outbound-transaction-1',
              'transaction_type' => 'outbound'
            }
          },
          {
            'lago_id' => 'consumption-2',
            'amount_cents' => 300,
            'created_at' => '2024-01-15T11:00:00Z',
            'wallet_transaction' => {
              'lago_id' => 'outbound-transaction-2',
              'transaction_type' => 'outbound'
            }
          }
        ],
        'meta' => {
          'current_page' => 1,
          'next_page' => nil,
          'prev_page' => nil,
          'total_pages' => 1,
          'total_count' => 2
        }
      }.to_json
    end

    before do
      stub_request(:get, "https://api.getlago.com/api/v1/wallet_transactions/#{wallet_transaction_id}/consumptions")
        .to_return(body: consumptions_response, status: 200)
    end

    it 'returns consumptions for the wallet transaction' do
      result = resource.consumptions(wallet_transaction_id)

      expect(result['wallet_transaction_consumptions'].count).to eq(2)
      expect(result['wallet_transaction_consumptions'].first['lago_id']).to eq('consumption-1')
      expect(result['wallet_transaction_consumptions'].first['amount_cents']).to eq(500)
      expect(result['wallet_transaction_consumptions'].first['wallet_transaction']['transaction_type']).to eq('outbound')
      expect(result['meta']['current_page']).to eq(1)
    end

    context 'with pagination options' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/wallet_transactions/#{wallet_transaction_id}/consumptions?per_page=1&page=2")
          .to_return(body: consumptions_response, status: 200)
      end

      it 'passes pagination parameters' do
        result = resource.consumptions(wallet_transaction_id, { per_page: 1, page: 2 })

        expect(result['wallet_transaction_consumptions']).not_to be_empty
      end
    end
  end

  describe '#fundings' do
    let(:wallet_transaction_id) { 'outbound-transaction-id' }
    let(:fundings_response) do
      {
        'wallet_transaction_fundings' => [
          {
            'lago_id' => 'funding-1',
            'amount_cents' => 500,
            'created_at' => '2024-01-15T10:00:00Z',
            'wallet_transaction' => {
              'lago_id' => 'inbound-transaction-1',
              'transaction_type' => 'inbound'
            }
          },
          {
            'lago_id' => 'funding-2',
            'amount_cents' => 300,
            'created_at' => '2024-01-15T11:00:00Z',
            'wallet_transaction' => {
              'lago_id' => 'inbound-transaction-2',
              'transaction_type' => 'inbound'
            }
          }
        ],
        'meta' => {
          'current_page' => 1,
          'next_page' => nil,
          'prev_page' => nil,
          'total_pages' => 1,
          'total_count' => 2
        }
      }.to_json
    end

    before do
      stub_request(:get, "https://api.getlago.com/api/v1/wallet_transactions/#{wallet_transaction_id}/fundings")
        .to_return(body: fundings_response, status: 200)
    end

    it 'returns fundings for the wallet transaction' do
      result = resource.fundings(wallet_transaction_id)

      expect(result['wallet_transaction_fundings'].count).to eq(2)
      expect(result['wallet_transaction_fundings'].first['lago_id']).to eq('funding-1')
      expect(result['wallet_transaction_fundings'].first['amount_cents']).to eq(500)
      expect(result['wallet_transaction_fundings'].first['wallet_transaction']['transaction_type']).to eq('inbound')
      expect(result['meta']['current_page']).to eq(1)
    end

    context 'with pagination options' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/wallet_transactions/#{wallet_transaction_id}/fundings?per_page=1&page=2")
          .to_return(body: fundings_response, status: 200)
      end

      it 'passes pagination parameters' do
        result = resource.fundings(wallet_transaction_id, { per_page: 1, page: 2 })

        expect(result['wallet_transaction_fundings']).not_to be_empty
      end
    end
  end

  describe '#create with priority' do
    let(:params) do
      {
        wallet_id: "123",
        name: "Transaction Name",
        paid_credits: "100",
        granted_credits: "100",
        priority: 5
      }
    end
    let(:body) do
      {
        'wallet_transaction' => {
          "wallet_id" => "123",
          "name" => "Transaction Name",
          "paid_credits" => "100",
          "granted_credits" => "100",
          "priority" => 5
        }
      }
    end
    let(:response_with_priority) do
      {
        'wallet_transactions' => [
          {
            'lago_id' => 'this-is-lago-id',
            'lago_wallet_id' => '123',
            'amount' => '100',
            'name' => 'Transaction Name',
            'priority' => 5,
            'status' => 'pending',
            'transaction_status' => 'purchased',
            'transaction_type' => 'inbound',
            'credit_amount' => '100',
            'remaining_amount_cents' => 10_000,
            'settled_at' => '2022-04-29T08:59:51Z',
            'created_at' => '2022-04-29T08:59:51Z'
          }
        ]
      }
    end

    before do
      stub_request(:post, 'https://api.getlago.com/api/v1/wallet_transactions')
        .with(body: body)
        .to_return(body: response_with_priority.to_json, status: 200)
    end

    it 'creates wallet transactions with priority' do
      wallet_transactions = resource.create(params)

      expect(wallet_transactions.first.lago_id).to eq('this-is-lago-id')
      expect(wallet_transactions.first.priority).to eq(5)
      expect(wallet_transactions.first.remaining_amount_cents).to eq(10_000)
    end
  end
end
