# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#customers.wallets.alerts', :integration do
  let(:customer) { create_customer(presets: [:us]) }
  let(:wallet) do
    client.customers.wallets.create(
      customer.external_id,
      {
        name: "Test Wallet #{customer_unique_id(customer)}",
        rate_amount: 2,
      },
    )
  end

  let(:alert_params) do
    {
      code: 'wallet_balance_alert',
      name: 'Wallet Balance Alert',
      alert_type: 'wallet_balance_amount',
      thresholds: [
        {
          code: 'alert',
          value: 1000,
          recurring: true,
        },
      ],
    }
  end
  let(:alert_code) { alert_params[:code] }

  def create_alert(customer, wallet, params)
    client.customers.wallets.alerts.create(customer.external_id, wallet.code, params)
  end

  def delete_alert(customer, wallet, alert_code)
    client.customers.wallets.alerts.destroy(customer.external_id, wallet.code, alert_code)
  end

  def get_alert(customer, wallet, alert_code)
    client.customers.wallets.alerts.get(customer.external_id, wallet.code, alert_code)
  end

  def have_alert_attributes(**params)
    have_attributes(
      lago_id: be_a(String),
      lago_organization_id: be_a(String),
      subscription_external_id: be_nil,
      external_subscription_id: be_nil,
      lago_wallet_id: wallet.lago_id,
      wallet_code: wallet.code,
      code: params[:code] || 'wallet_balance_alert',
      name: params[:name] || 'Wallet Balance Alert',
      alert_type: 'wallet_balance_amount',
      thresholds: [
        have_attributes(
          code: 'alert',
          value: '1000.0',
          recurring: true,
        ),
      ],
      direction: be_a(String),
      previous_value: be_a(String),
      last_processed_at: be_nil,
      created_at: be_a(String),
      billable_metric: be_nil,
    )
  end

  describe '#create' do
    after { delete_alert(customer, wallet, alert_code) }

    it 'creates an alert' do
      alert = create_alert(customer, wallet, alert_params)

      expect(alert).to have_alert_attributes
    end
  end

  describe '#update' do
    before { create_alert(customer, wallet, alert_params) }
    after { delete_alert(customer, wallet, alert_code) }

    let(:name) { 'New Wallet Balance Alert' }

    it 'updates an alert' do
      alert = client.customers.wallets.alerts.update(
        customer.external_id,
        wallet.code,
        alert_code,
        { name: },
      )

      expect(alert).to have_alert_attributes(name:)
    end
  end

  describe '#get' do
    before { create_alert(customer, wallet, alert_params) }
    after { delete_alert(customer, wallet, alert_code) }

    it 'gets a wallet' do
      alert = client.customers.wallets.alerts.get(customer.external_id, wallet.code, alert_code)

      expect(alert).to have_alert_attributes
    end
  end

  describe '#get_all' do
    before { create_alert(customer, wallet, alert_params) }
    after { delete_alert(customer, wallet, alert_code) }

    it 'gets all allerts' do
      result = client.customers.wallets.alerts.get_all(customer.external_id, wallet.code)

      expect(result.meta).to have_attributes(
        current_page: 1,
        next_page: nil,
        prev_page: nil,
        total_count: 1,
        total_pages: 1,
      )

      expect(result.alerts.first).to have_alert_attributes
    end
  end

  describe '#destroy' do
    before { create_alert(customer, wallet, alert_params) }

    it 'deletes an alert' do
      delete_alert(customer, wallet, alert_code)

      expect { get_alert(customer, wallet, alert_code) }.to raise_error(Lago::Api::HttpError)
    end
  end
end
