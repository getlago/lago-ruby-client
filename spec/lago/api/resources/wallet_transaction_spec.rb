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

    context 'when payment_method is provided' do
      let(:params_with_pm) do
        {
          wallet_id: '123',
          name: 'Transaction Name',
          paid_credits: '100',
          granted_credits: '100',
          voided_credits: '0',
          payment_method: {
            payment_method_type: 'provider',
            payment_method_id: 'pm-wt-123',
          },
        }
      end
      let(:body_with_pm) do
        {
          'wallet_transaction' => {
            'wallet_id' => '123',
            'name' => 'Transaction Name',
            'paid_credits' => '100',
            'granted_credits' => '100',
            'voided_credits' => '0',
            'payment_method' => {
              'payment_method_type' => 'provider',
              'payment_method_id' => 'pm-wt-123',
            },
          },
        }
      end
      let(:response_with_pm) do
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
              'created_at' => '2022-04-29T08:59:51Z',
              'payment_method' => {
                'payment_method_type' => 'provider',
                'payment_method_id' => 'pm-wt-123',
              },
            },
          ],
        }
      end

      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/wallet_transactions')
          .with(body: body_with_pm)
          .to_return(body: response_with_pm.to_json, status: 200)
      end

      it 'returns wallet_transactions with payment method', :aggregate_failures do
        wallet_transactions = resource.create(params_with_pm)

        expect(wallet_transactions.first.lago_id).to eq('this-is-lago-id')
        expect(wallet_transactions.first.payment_method.payment_method_type).to eq('provider')
        expect(wallet_transactions.first.payment_method.payment_method_id).to eq('pm-wt-123')
      end

      context 'when payment_method is invalid' do
        let(:error_response) do
          {
            'status' => 422,
            'error' => 'Unprocessable Entity',
            'code' => 'validation_errors',
            'error_details' => {
              'payment_method' => ['invalid_payment_method'],
            },
          }.to_json
        end

        before do
          stub_request(:post, 'https://api.getlago.com/api/v1/wallet_transactions')
            .with(body: body_with_pm)
            .to_return(body: error_response, status: 422)
        end

        it 'raises an error' do
          expect { resource.create(params_with_pm) }.to raise_error Lago::Api::HttpError
        end
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
end
