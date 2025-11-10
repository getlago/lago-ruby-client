# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#payment_requests', :integration do
  describe '#create' do
    before_all_integration_tests do
      @customer = create_customer(presets: [:us])
      @add_on = client.add_ons.create(
        external_customer_id: customer.external_id,
        name: "Test Add-On #{customer_unique_id}",
        code: "test-add-on-#{customer_unique_id}",
        amount_cents: 1000,
        amount_currency: customer.currency,
      )
      @invoice = client.invoices.create(
        external_customer_id: customer.external_id,
        currency: customer.currency,
        issue_date: Date.parse('2025-08-08'),
        fees: [
          {
            add_on_code: add_on.code,
            unit_amount_cents: 1000,
            units: 1,
            description: "Test Fee #{customer_unique_id}",
            invoice_display_name: "Test Fee #{customer_unique_id}",
          },
        ],
      )
    end

    attr_reader :customer, :add_on, :invoice, :payment

    def customer_unique_id
      super(customer)
    end

    it 'retrieves payment receipts' do
      payment_request = client.payment_requests.create(
        external_customer_id: 'cust_2',
        email: "tech+ruby-#{customer_unique_id}@getlago.com",
        lago_invoice_ids: ['5312741e-ea25-4e34-aaf4-5a392e50d95c'],
      )

      expect(payment_request.to_h).to eq({})
    end
  end
end
