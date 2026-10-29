# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#wallet_transactions', :integration do
  let(:customer) { create_customer(presets: [:us]) }
  let(:wallet) do
    client.wallets.create(
      external_customer_id: customer.external_id,
      name: "Test Wallet #{customer_unique_id(customer)}",
      rate_amount: '1',
      currency: 'USD',
    )
  end

  describe '#create' do
    it 'creates a wallet transaction with the given priority' do
      wallet_transactions = client.wallet_transactions.create(
        wallet_id: wallet.lago_id,
        granted_credits: '20',
        priority: 10,
      )

      expect(wallet_transactions).not_to be_empty
      expect(wallet_transactions).to all(have_attributes(priority: 10))
    end

    it 'voids credits from the given inbound transaction' do
      inbound = client.wallet_transactions.create(wallet_id: wallet.lago_id, granted_credits: '20').first

      wait_until do
        transactions = client.wallet_transactions.get_all(wallet.lago_id).wallet_transactions
        transactions.any? { |transaction| transaction.lago_id == inbound.lago_id && transaction.status == 'settled' }
      end

      wallet_transactions = client.wallet_transactions.create(
        wallet_id: wallet.lago_id,
        voided_credits: '5',
        voided_transaction_id: inbound.lago_id,
      )

      voided = wallet_transactions.find { |transaction| transaction.transaction_status == 'voided' }
      expect(voided).to have_attributes(transaction_type: 'outbound', credit_amount: '5.0')

      wait_until do
        client.wallets.get(wallet.lago_id).credits_balance == '15.0'
      end
    end
  end
end
