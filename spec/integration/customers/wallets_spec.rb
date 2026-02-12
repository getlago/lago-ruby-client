# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#customers.wallets', :integration do
  def create_wallet(customer)
    name = "Test Wallet #{customer_unique_id(customer)}"
    client.customers.wallets.create(
      customer.external_id,
      {
        name:,
        priority: 30,
        rate_amount: 2,
        granted_credits: '10.0',
        paid_credits: '20.0',
        currency: customer.currency,
        metadata: {
          key: 'value',
        },
      },
    )
  end

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
    expect(wallet.expiration_at).to be_nil
    expect(wallet.external_customer_id).to eq customer.external_id
    expect(wallet.invoice_requires_successful_payment).to be false
    expect(wallet.lago_customer_id).to eq customer.lago_id
    expect(wallet.lago_id).to be_present
    expect(wallet.last_balance_sync_at).to attributes[:last_balance_sync_at] || be_nil
    expect(wallet.last_consumed_credit_at).to be_nil
    expect(wallet.name).to(attributes[:name] ? eq(attributes[:name]) : be_present)
    expect(wallet.ongoing_balance_cents).to eq attributes[:ongoing_balance_cents] || 0
    expect(wallet.ongoing_usage_balance_cents).to eq attributes[:ongoing_usage_balance_cents] || 0
    expect(wallet.paid_top_up_max_amount_cents).to be_nil
    expect(wallet.paid_top_up_min_amount_cents).to be_nil
    expect(wallet.priority).to eq 30
    expect(wallet.rate_amount).to eq '2.0'
    expect(wallet.recurring_transaction_rules).to eq []
    expect(wallet.status).to eq 'active'
    expect(wallet.terminated_at).to be_nil
  end

  def assert_wallet_attributes_with_updated_balance(wallet, **attributes)
    assert_wallet_attributes(
      wallet,
      credits_balance: '10.0',
      balance_cents: 2000,
      ongoing_balance_cents: 2000,
      credits_ongoing_balance: '10.0',
      last_balance_sync_at: be_present,

      **attributes,
    )
  end

  def wait_for_balance_update(wallet)
    new_wallet = nil
    wait_until do
      new_wallet = client.customers.wallets.get(wallet.external_customer_id, wallet.code)
      new_wallet.balance_cents == 2000
    end
    new_wallet
  end

  describe '#create' do
    let(:customer) { create_customer(presets: [:us]) }

    it 'creates a wallet' do
      wallet = create_wallet(customer)
      assert_wallet_attributes(wallet, name: "Test Wallet #{customer_unique_id(customer)}")
    end
  end

  describe '#update' do
    let(:customer) { create_customer(presets: [:us]) }
    let(:wallet) { create_wallet(customer) }

    it 'updates a wallet' do
      wait_for_balance_update(wallet) # avoid race condition

      updated_wallet = client.customers.wallets.update(
        wallet.external_customer_id,
        wallet.code,
        { name: "Updated Wallet #{customer_unique_id(customer)}" },
      )
      assert_wallet_attributes_with_updated_balance(
        updated_wallet,
        name: "Updated Wallet #{customer_unique_id(customer)}",
      )
    end
  end

  describe '#get' do
    let(:customer) { create_customer(presets: [:us]) }
    let(:existing_wallet) { create_wallet(customer) }

    before do
      wait_for_balance_update(existing_wallet)
    end

    it 'gets a wallet' do
      wallet = client.customers.wallets.get(existing_wallet.external_customer_id, existing_wallet.code)

      assert_wallet_attributes_with_updated_balance(wallet, name: "Test Wallet #{customer_unique_id(customer)}")
    end
  end

  describe '#get_all' do
    let(:customer) { create_customer(presets: [:us]) }

    before do
      wallet = create_wallet(customer)
      wait_for_balance_update(wallet)
    end

    it 'gets all wallets' do
      result = client.customers.wallets.get_all(customer.external_id)

      meta = result.meta
      expect(meta.current_page).to eq 1
      expect(meta.next_page).to be_nil
      expect(meta.prev_page).to be_nil
      expect(meta.total_count).to eq 1
      expect(meta.total_pages).to eq 1

      expect(result.wallets.count).to eq 1
      wallet = result.wallets.first
      assert_wallet_attributes_with_updated_balance(wallet, name: "Test Wallet #{customer_unique_id(customer)}")
    end
  end

  describe '#destroy' do
    let(:customer) { create_customer(presets: [:us]) }
    let(:wallet) { create_wallet(customer) }

    before do
      # ensures there's no race condition
      wait_for_balance_update(wallet)
    end

    it 'deletes a wallet' do
      client.customers.wallets.destroy(wallet.external_customer_id, wallet.code)

      destroyed_wallet = client.customers.wallets.get(wallet.external_customer_id, wallet.code)
      #expect(destroyed_wallet.terminated_at).to be_present
      expect(destroyed_wallet.status).to eq 'terminated'
    end
  end
end
