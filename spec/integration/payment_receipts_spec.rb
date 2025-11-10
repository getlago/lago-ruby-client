# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#payment_receipts', :integration do
  describe '#index' do
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
      @payment = client.payments.create(
        external_customer_id: customer.external_id,
        currency: customer.currency,
        amount_cents: 1000,
        amount_currency: customer.currency,
        invoice_id: invoice.lago_id,
        reference: "Test Payment #{customer_unique_id}",
      )
    end

    attr_reader :customer, :add_on, :invoice, :payment

    def customer_unique_id
      super(customer)
    end

    it 'retrieves payment receipts' do
      result = nil
      wait_until do
        result = client.payment_receipts.get_all(
          invoice_id: invoice.lago_id,
        )
        result.payment_receipts.any? { |r| r.payment.invoice_ids.include?(invoice.lago_id) }
      end

      payment_receipt = result.payment_receipts.first

      expect(payment_receipt.created_at).to be_present
      expect(payment_receipt.file_url).to eq nil
      expect(payment_receipt.lago_id).to be_present
      expect(payment_receipt.number).to be_present
      expect(payment_receipt.xml_url).to eq nil

      payment = payment_receipt.payment
      expect(payment.amount_cents).to eq 1000
      expect(payment.amount_currency).to eq 'USD'
      expect(payment.created_at).to be_present
      expect(payment.external_customer_id).to eq customer.external_id
      expect(payment.external_payment_id).to eq nil
      expect(payment.invoice_ids).to eq [invoice.lago_id]
      expect(payment.lago_customer_id).to eq customer.lago_id
      expect(payment.lago_id).to be_present
      expect(payment.lago_payable_id).to eq invoice.lago_id
      expect(payment.next_action.to_h).to eq({})
      expect(payment.payable_type).to eq 'Invoice'
      expect(payment.payment_provider_code).to eq nil
      expect(payment.payment_provider_type).to eq nil
      expect(payment.payment_status).to eq 'succeeded'
      expect(payment.provider_customer_id).to eq nil
      expect(payment.provider_payment_id).to eq nil
      expect(payment.reference).to eq "Test Payment #{customer_unique_id}"
      expect(payment.status).to eq 'succeeded'
      expect(payment.type).to eq 'manual'
    end
  end
end
