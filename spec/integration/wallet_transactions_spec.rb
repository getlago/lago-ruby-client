# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#wallet_transactions', :integration do
  def create_wallet(customer, params = {})
    name = "Test Wallet #{customer_unique_id(customer)}"
    client.wallets.create(
      {
        external_customer_id: customer.external_id,
        name:,
        rate_amount: 1,
        granted_credits: '100.0',
        paid_credits: '100.0',
        currency: customer.currency,
      }.merge(params),
    )
  end

  def wait_for_wallet_balance(wallet_id, expected_balance_cents)
    wallet = nil
    wait_until do
      wallet = client.wallets.get(wallet_id)
      wallet.balance_cents == expected_balance_cents
    end
    wallet
  end

  describe '#create' do
    let(:customer) { create_customer(presets: [:us]) }
    let(:wallet) { create_wallet(customer) }

    before do
      wait_for_wallet_balance(wallet.lago_id, 20_000)
    end

    it 'creates wallet transactions' do
      transactions = client.wallet_transactions.create(
        wallet_id: wallet.lago_id,
        paid_credits: '50.0',
        granted_credits: '25.0',
      )

      expect(transactions).to be_an(Array)
      expect(transactions.count).to eq(2)
      expect(transactions).to all(have_attributes(lago_wallet_id: wallet.lago_id))
    end

    context 'with priority' do
      it 'creates wallet transactions with the specified priority' do
        transactions = client.wallet_transactions.create(
          wallet_id: wallet.lago_id,
          paid_credits: '10.0',
          granted_credits: '5.0',
          priority: 5,
        )

        expect(transactions).to be_an(Array)
        expect(transactions.count).to eq(2)
        expect(transactions).to all(have_attributes(priority: 5))
      end
    end
  end

  describe '#create with transaction_priority on wallet' do
    let(:customer) { create_customer(presets: [:us]) }

    it 'creates wallet with initial transactions having the specified priority' do
      wallet = client.wallets.create(
        external_customer_id: customer.external_id,
        name: "Priority Wallet #{customer_unique_id(customer)}",
        rate_amount: 1,
        granted_credits: '50.0',
        paid_credits: '50.0',
        currency: customer.currency,
        transaction_priority: 10,
      )

      wait_for_wallet_balance(wallet.lago_id, 10_000)

      transactions = client.wallet_transactions.get_all(wallet.lago_id)
      expect(transactions['wallet_transactions']).to all(include('priority' => 10))
    end
  end

  describe '#get_all' do
    let(:customer) { create_customer(presets: [:us]) }
    let(:wallet) { create_wallet(customer) }

    before do
      wait_for_wallet_balance(wallet.lago_id, 20_000)
    end

    it 'returns all wallet transactions for a wallet' do
      result = client.wallet_transactions.get_all(wallet.lago_id)

      expect(result['wallet_transactions']).to be_an(Array)
      expect(result['wallet_transactions'].count).to eq(2)
      expect(result['meta']['total_count']).to eq(2)
    end

    context 'with pagination' do
      it 'paginates results' do
        result = client.wallet_transactions.get_all(wallet.lago_id, { per_page: 1, page: 1 })

        expect(result['wallet_transactions'].count).to eq(1)
        expect(result['meta']['current_page']).to eq(1)
        expect(result['meta']['total_pages']).to eq(2)
      end
    end
  end

  describe '#get' do
    let(:customer) { create_customer(presets: [:us]) }
    let(:wallet) { create_wallet(customer) }

    before do
      wait_for_wallet_balance(wallet.lago_id, 20_000)
    end

    it 'returns a single wallet transaction' do
      transactions = client.wallet_transactions.get_all(wallet.lago_id)
      transaction_id = transactions['wallet_transactions'].first['lago_id']

      transaction = client.wallet_transactions.get(transaction_id)

      expect(transaction.lago_id).to eq(transaction_id)
      expect(transaction.lago_wallet_id).to eq(wallet.lago_id)
      expect(transaction.remaining_amount_cents).to be_present
      expect(transaction.priority).to be_present
    end
  end
end
