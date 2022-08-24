# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::WalletTransaction do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:factory_wallet_transaction) { FactoryBot.build(:wallet_transaction) }
  let(:response) do
    {
      'wallet_transaction' => {
        'lago_id' => 'this-is-lago-id',
        'lago_wallet_id' => factory_wallet_transaction.wallet_id,
        'paid_credits' => factory_wallet_transaction.paid_credits,
        'granted_credits' => factory_wallet_transaction.granted_credits,
        'created_at' => '2022-04-29T08:59:51Z'
      }
    }.to_json
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
          .to_return(body: response, status: 200)
      end

      it 'returns an wallet_transaction' do
        wallet_transaction = resource.create(params)

        expect(wallet_transaction.lago_id).to eq('this-is-lago-id')
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
end
