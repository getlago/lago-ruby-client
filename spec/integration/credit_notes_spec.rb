# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#credit_notes', :integration, :premium do
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

    attr_reader :customer, :add_on, :invoice

    def customer_unique_id
      super(customer)
    end

    it 'creates a credit note' do
      credit_note = client.credit_notes.create(
        external_customer_id: customer.external_id,
        currency: customer.currency,
        fees: [
          {
            add_on_code: add_on.code,
          },
        ],
        invoice_id: invoice.lago_id,
        reason: :order_cancellation,
        credit_amount_cents: 500,
        items: [
          {
            fee_id: invoice.fees.first.lago_id,
            amount_cents: 500,
          },
        ],
      )

      expect(credit_note.applied_taxes).to eq []
      expect(credit_note.balance_amount_cents).to eq 500
      expect(credit_note.billing_entity_code).to eq 'hooli'
      expect(credit_note.coupons_adjustment_amount_cents).to eq 0
      expect(credit_note.created_at).to be_present
      expect(credit_note.credit_amount_cents).to eq 500
      expect(credit_note.credit_status).to eq 'available'
      expect(credit_note.currency).to eq 'USD'
      expect(credit_note.description).to eq nil
      expect(credit_note.file_url).to eq nil
      expect(credit_note.invoice_number).to eq invoice.number
      expect(credit_note.issuing_date).to eq Date.today.iso8601
      expect(credit_note.lago_id).to be_present
      expect(credit_note.lago_invoice_id).to eq invoice.lago_id
      expect(credit_note.number).to be_present
      expect(credit_note.precise_taxes_amount_cents).to eq '0.0'
      expect(credit_note.precise_total_amount_cents).to eq '500.0'
      expect(credit_note.reason).to eq 'order_cancellation'
      expect(credit_note.refund_amount_cents).to eq 0
      expect(credit_note.refund_status).to eq nil
      expect(credit_note.self_billed).to eq false
      expect(credit_note.sequential_id).to be_present
      expect(credit_note.sub_total_excluding_taxes_amount_cents).to eq 500
      expect(credit_note.taxes_amount_cents).to eq 0
      expect(credit_note.taxes_rate).to eq 0.0
      expect(credit_note.total_amount_cents).to eq 500
      expect(credit_note.updated_at).to be_present

      items = credit_note.items
      expect(items.count).to eq 1

      item = items.first
      expect(item.amount_cents).to eq 500
      expect(item.amount_currency).to eq 'USD'
      expect(item.lago_id).to be_present
      expect(item.precise_amount_cents).to eq '500.0'

      item_fee = item.fee
      expect(item_fee.amount_cents).to eq 1000
      expect(item_fee.amount_currency).to eq 'USD'
      expect(item_fee.amount_details.to_h).to eq({})
      expect(item_fee.created_at).to be_present
      expect(item_fee.description).to eq "Test Fee #{customer_unique_id}"
      expect(item_fee.events_count).to eq nil
      expect(item_fee.external_customer_id).to eq nil
      expect(item_fee.external_subscription_id).to eq nil
      expect(item_fee.failed_at).to eq nil
      expect(item_fee.from_date).to be_present
      expect(item_fee.invoiceable).to eq true
      expect(item_fee.lago_charge_filter_id).to eq nil
      expect(item_fee.lago_charge_id).to eq nil
      expect(item_fee.lago_customer_id).to eq nil
      expect(item_fee.lago_id).to be_present
      expect(item_fee.lago_invoice_id).to be_present
      expect(item_fee.lago_subscription_id).to eq nil
      expect(item_fee.lago_true_up_fee_id).to eq nil
      expect(item_fee.lago_true_up_parent_fee_id).to eq nil
      expect(item_fee.pay_in_advance).to eq false
      expect(item_fee.payment_status).to eq 'pending'
      expect(item_fee.precise_amount).to eq '10.0'
      expect(item_fee.precise_coupons_amount_cents).to eq '0.0'
      expect(item_fee.precise_total_amount).to eq '10.0'
      expect(item_fee.precise_unit_amount).to eq '10.0'
      expect(item_fee.pricing_unit_details).to eq nil
      expect(item_fee.refunded_at).to eq nil
      expect(item_fee.self_billed).to eq false
      expect(item_fee.succeeded_at).to eq nil
      expect(item_fee.taxes_amount_cents).to eq 0
      expect(item_fee.taxes_precise_amount).to eq '0.0'
      expect(item_fee.taxes_rate).to eq 0.0
      expect(item_fee.to_date).to be_present
      expect(item_fee.total_aggregated_units).to eq nil
      expect(item_fee.total_amount_cents).to eq 1000
      expect(item_fee.total_amount_currency).to eq 'USD'
      expect(item_fee.units).to eq '1.0'

      item_fee_item = item_fee.item
      expect(item_fee_item.code).to eq "test-add-on-#{customer_unique_id}"
      expect(item_fee_item.description).to eq nil
      expect(item_fee_item.filter_invoice_display_name).to eq nil
      expect(item_fee_item.filters).to eq nil
      expect(item_fee_item.grouped_by.to_h).to eq({})
      expect(item_fee_item.invoice_display_name).to eq "Test Fee #{customer_unique_id}"
      expect(item_fee_item.item_type).to eq 'AddOn'
      expect(item_fee_item.lago_item_id).to eq add_on.lago_id
      expect(item_fee_item.name).to eq "Test Add-On #{customer_unique_id}"
      expect(item_fee_item.type).to eq 'add_on'
    end
  end
end
