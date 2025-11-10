# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#wallets', :integration do
  describe '#create' do
    before_all_integration_tests do
      @customer = create_customer(presets: [:us], context: 'wallet-create')
    end

    attr_reader :customer

    def assert_wallet_attributes(wallet, **attributes)
      expect(wallet.applies_to.fee_types).to eq []
      expect(wallet.applies_to.billable_metric_codes).to eq []
      expect(wallet.balance_cents).to eq attributes[:balance_cents] || 0
      expect(wallet.consumed_credits).to eq '0.0'
      expect(wallet.created_at).to be_present
      expect(wallet.credits_balance).to eq attributes[:credits_balance] || '0.0'
      expect(wallet.credits_ongoing_balance).to eq attributes[:credits_ongoing_balance] || '0.0'
      expect(wallet.credits_ongoing_usage_balance).to eq attributes[:credits_ongoing_usage_balance] || '0.0'
      expect(wallet.currency).to eq 'USD'
      expect(wallet.expiration_at).to eq nil
      expect(wallet.external_customer_id).to eq customer.external_id
      expect(wallet.invoice_requires_successful_payment).to eq false
      expect(wallet.lago_customer_id).to eq customer.lago_id
      expect(wallet.lago_id).to be_present
      expect(wallet.last_balance_sync_at).to attributes[:last_balance_sync_at] || eq(nil)
      expect(wallet.last_consumed_credit_at).to eq nil
      expect(wallet.name).to(attributes[:name] ? eq(attributes[:name]) : be_present)
      expect(wallet.ongoing_balance_cents).to eq attributes[:ongoing_balance_cents] || 0
      expect(wallet.ongoing_usage_balance_cents).to eq attributes[:ongoing_usage_balance_cents] || 0
      expect(wallet.paid_top_up_max_amount_cents).to eq nil
      expect(wallet.paid_top_up_min_amount_cents).to eq nil
      expect(wallet.priority).to eq 50
      expect(wallet.rate_amount).to eq '2.0'
      expect(wallet.recurring_transaction_rules).to eq []
      expect(wallet.status).to eq 'active'
      expect(wallet.terminated_at).to eq nil
    end

    def wait_for_balance_update(wallet_id)
      wallet = nil
      wait_until do
        wallet = client.wallets.get(wallet_id)
        wallet.balance_cents == 2000
      end
      wallet
    end

    it 'creates a wallet' do
      name = "Test Wallet #{customer_unique_id(customer)}"
      wallet = client.wallets.create(
        external_customer_id: customer.external_id,
        name:,
        rate_amount: 2,
        granted_credits: '10.0',
        paid_credits: '20.0',
        currency: customer.currency,
        metadata: {
          key: 'value',
        },
      )

      assert_wallet_attributes(wallet, name:)

      # Wait for balance to be updated
      wallet = wait_for_balance_update(wallet.lago_id)

      assert_wallet_attributes(
        wallet,
        credits_balance: '10.0',
        balance_cents: 2000,
        ongoing_balance_cents: 2000,
        credits_ongoing_balance: '10.0',
        last_balance_sync_at: be_present,
      )
    end
  end
end
