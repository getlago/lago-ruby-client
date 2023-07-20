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
          'status' => 'pending',
          'transaction_type' => 'inbound',
          'credit_amount' => factory_wallet_transaction.paid_credits,
          'settled_at' => '2022-04-29T08:59:51Z',
          'created_at' => '2022-04-29T08:59:51Z'
        },
        {
          'lago_id' => 'this-is-lago-id2',
          'lago_wallet_id' => factory_wallet_transaction.wallet_id,
          'amount' => factory_wallet_transaction.granted_credits,
          'status' => 'settled',
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
    let(:params) { factory_wallet_transaction.to_h }
    let(:body) do
      {
        'wallet_transaction' => factory_wallet_transaction.to_h
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
end
