# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#invoices', :integration do
  describe '#create' do
    before_all_integration_tests do
      @customer = create_customer(presets: [:us], context: 'invoice-create')
      @add_on = client.add_ons.create(
        external_customer_id: customer.external_id,
        name: "Test Add-On #{customer_unique_id}",
        code: "test-add-on-#{customer_unique_id}",
        amount_cents: 1000,
        amount_currency: customer.currency,
      )
    end

    attr_reader :customer, :add_on

    def customer_unique_id
      super(customer)
    end

    it 'creates a one-off invoice' do
      invoice = client.invoices.create(
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

      expect(invoice.applied_invoice_custom_sections).to eq []
      expect(invoice.applied_taxes).to eq []
      expect(invoice.billing_entity_code).to eq 'hooli'
      expect(invoice.billing_periods).to eq []
      expect(invoice.coupons_amount_cents).to eq 0
      expect(invoice.created_at).to be_present
      expect(invoice.credit_notes_amount_cents).to eq 0
      expect(invoice.credits).to eq []
      expect(invoice.currency).to eq 'USD'
      expect(invoice.error_details).to eq []
      expect(invoice.fees_amount_cents).to eq 1000
      expect(invoice.file_url).to eq nil
      expect(invoice.invoice_type).to eq 'one_off'
      expect(invoice.issuing_date).to eq Date.today.iso8601
      expect(invoice.lago_id).to be_present
      expect(invoice.metadata).to eq []
      expect(invoice.net_payment_term).to eq 0
      expect(invoice.number).to be_present
      expect(invoice.payment_dispute_lost_at).to eq nil
      expect(invoice.payment_due_date).to eq Date.today.iso8601
      expect(invoice.payment_overdue).to eq false
      expect(invoice.payment_status).to eq 'pending'
      expect(invoice.prepaid_credit_amount_cents).to eq 0
      expect(invoice.progressive_billing_credit_amount_cents).to eq 0
      expect(invoice.self_billed).to eq false
      expect(invoice.sequential_id).to eq 1
      expect(invoice.status).to eq 'finalized'
      expect(invoice.sub_total_excluding_taxes_amount_cents).to eq 1000
      expect(invoice.sub_total_including_taxes_amount_cents).to eq 1000
      expect(invoice.subscriptions).to eq []
      expect(invoice.taxes_amount_cents).to eq 0
      expect(invoice.total_amount_cents).to eq 1000
      expect(invoice.total_due_amount_cents).to eq 1000
      expect(invoice.updated_at).to be_present
      expect(invoice.version_number).to eq 4
      expect(invoice.voided_at).to eq nil
      expect(invoice.xml_url).to eq nil

      fees = invoice.fees
      expect(fees.length).to eq 1

      fee = fees.first
      expect(fee.amount_cents).to eq 1000
      expect(fee.amount_currency).to eq 'USD'
      expect(fee.amount_details.to_h).to eq({})
      expect(fee.created_at).to be_present
      expect(fee.description).to eq "Test Fee #{customer_unique_id}"
      expect(fee.events_count).to eq nil
      expect(fee.external_customer_id).to eq nil
      expect(fee.external_subscription_id).to eq nil
      expect(fee.failed_at).to eq nil
      expect(fee.from_date).to be_present
      expect(fee.invoiceable).to eq true
      expect(fee.lago_charge_filter_id).to eq nil
      expect(fee.lago_charge_id).to eq nil
      expect(fee.lago_customer_id).to eq nil
      expect(fee.lago_id).to be_present
      expect(fee.lago_invoice_id).to eq invoice.lago_id
      expect(fee.lago_subscription_id).to eq nil
      expect(fee.lago_true_up_fee_id).to eq nil
      expect(fee.lago_true_up_parent_fee_id).to eq nil
      expect(fee.pay_in_advance).to eq false
      expect(fee.payment_status).to eq 'pending'
      expect(fee.precise_amount).to eq '10.0'
      expect(fee.precise_coupons_amount_cents).to eq '0.0'
      expect(fee.precise_total_amount).to eq '10.0'
      expect(fee.precise_unit_amount).to eq '10.0'
      expect(fee.pricing_unit_details).to eq nil
      expect(fee.refunded_at).to eq nil
      expect(fee.self_billed).to eq false
      expect(fee.succeeded_at).to eq nil
      expect(fee.taxes_amount_cents).to eq 0
      expect(fee.taxes_precise_amount).to eq '0.0'
      expect(fee.taxes_rate).to eq 0.0
      expect(fee.to_date).to be_present
      expect(fee.total_aggregated_units).to eq nil
      expect(fee.total_amount_cents).to eq 1000
      expect(fee.total_amount_currency).to eq 'USD'
      expect(fee.units).to eq '1.0'

      fee_item = fee.item
      expect(fee_item.code).to eq "test-add-on-#{customer_unique_id}"
      expect(fee_item.description).to eq nil
      expect(fee_item.filter_invoice_display_name).to eq nil
      expect(fee_item.filters).to eq nil
      expect(fee_item.grouped_by.to_h).to eq({})
      expect(fee_item.invoice_display_name).to eq "Test Fee #{customer_unique_id}"
      expect(fee_item.item_type).to eq 'AddOn'
      expect(fee_item.lago_item_id).to eq add_on.lago_id
      expect(fee_item.name).to eq "Test Add-On #{customer_unique_id}"
      expect(fee_item.type).to eq 'add_on'

      suffix_regex = unique_id_regex('invoice-create')

      customer = invoice.customer
      expect(customer).to be_present
      expect(customer.account_type).to eq 'customer'
      expect(customer.address_line1).to eq '123 Main St'
      expect(customer.address_line2).to eq 'Apt 1'
      expect(customer.applicable_timezone).to be_present
      expect(customer.billing_entity_code).to eq 'hooli'
      expect(customer.city).to eq 'San Francisco'
      expect(customer.country).to eq 'US'
      expect(customer.created_at).to be_present
      expect(customer.currency).to eq 'USD'
      expect(customer.customer_type).to eq nil
      expect(customer.email).to match(/yohan\+#{suffix_regex}@getlago\.com$/)
      expect(customer.external_id).to match(/^ExternalID #{suffix_regex}$/)
      expect(customer.external_salesforce_id).to eq nil
      expect(customer.finalize_zero_amount_invoice).to eq 'inherit'
      expect(customer.firstname).to match(/^Firstname #{suffix_regex}$/)
      expect(customer.integration_customers).to eq []
      expect(customer.lago_id).to be_present
      expect(customer.lastname).to match(/^Lastname #{suffix_regex}$/)
      expect(customer.legal_name).to match(/^LegalName #{suffix_regex}$/)
      expect(customer.legal_number).to eq 'US1234567890'
      expect(customer.logo_url).to eq nil
      expect(customer.metadata).to eq []
      expect(customer.name).to match(/^Name \| #{suffix_regex}$/)
      expect(customer.net_payment_term).to eq nil
      expect(customer.phone).to eq '0601020304'
      expect(customer.sequential_id).to be_present
      expect(customer.skip_invoice_custom_sections).to eq false
      expect(customer.slug).to be_present
      expect(customer.state).to eq 'CA'
      expect(customer.tax_identification_number).to eq nil
      expect(customer.timezone).to eq(nil).or(be_present)
      expect(customer.updated_at).to be_present
      expect(customer.url).to eq nil
      expect(customer.zipcode).to eq '94101'

      customer_shipping_address = customer.shipping_address
      expect(customer_shipping_address).to be_present
      expect(customer_shipping_address.address_line1).to eq nil
      expect(customer_shipping_address.address_line2).to eq nil
      expect(customer_shipping_address.city).to eq nil
      expect(customer_shipping_address.zipcode).to eq nil
      expect(customer_shipping_address.state).to eq nil
      expect(customer_shipping_address.country).to eq nil

      customer_billing_configuration = customer.billing_configuration
      expect(customer_billing_configuration).to be_present
      expect(customer_billing_configuration.invoice_grace_period).to eq nil
      expect(customer_billing_configuration.payment_provider).to eq nil
      expect(customer_billing_configuration.payment_provider_code).to eq nil
      expect(customer_billing_configuration.document_locale).to eq nil
    end
  end
end
