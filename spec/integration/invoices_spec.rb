# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#invoices', :integration do
  before_all_integration_tests do
    @customer = create_customer(presets: [:us, :with_searchable_attributes])
    @add_on = client.add_ons.create(
      external_customer_id: customer.external_id,
      name: "Test Add-On #{unique_id}",
      code: "test-add-on-#{unique_id}",
      amount_cents: 1000,
      amount_currency: customer.currency,
    )
  end

  attr_reader :customer, :add_on

  def create_one_off_invoice(customer: self.customer, fees: nil)
    fees ||= [
      {
        add_on_code: add_on.code,
        unit_amount_cents: 1000,
        units: 1,
        description: "Test Fee #{customer_unique_id(customer)}",
        invoice_display_name: "Test Fee #{customer_unique_id(customer)}",
      },
    ]
    client.invoices.create(
      external_customer_id: customer.external_id,
      currency: customer.currency,
      fees:,
    )
  end

  def assert_invoice_customer_attributes(invoice, customer)
    suffix_regex = unique_id_regex

    invoice_customer = invoice.customer
    expect(invoice_customer).to be_present
    expect(invoice_customer.account_type).to eq 'customer'
    expect(invoice_customer.address_line1).to eq '123 Main St'
    expect(invoice_customer.address_line2).to eq 'Apt 1'
    expect(invoice_customer.applicable_timezone).to be_present
    expect(invoice_customer.billing_entity_code).to eq 'hooli'
    expect(invoice_customer.city).to be_present
    expect(invoice_customer.country).to be_present
    expect(invoice_customer.created_at).to be_present
    expect(invoice_customer.currency).to eq(customer.currency)
    expect(invoice_customer.customer_type).to be_nil
    expect(invoice_customer.email).to match(/yohan\+#{suffix_regex}@getlago\.com$/)
    expect(invoice_customer.external_id).to match(/^ExternalID #{suffix_regex}$/)
    expect(invoice_customer.external_salesforce_id).to be_nil
    expect(invoice_customer.finalize_zero_amount_invoice).to eq 'inherit'
    expect(invoice_customer.firstname).to match(/^Firstname #{suffix_regex}$/)
    expect(invoice_customer.integration_customers).to eq []
    expect(invoice_customer.lago_id).to be_present
    expect(invoice_customer.lastname).to match(/^Lastname #{suffix_regex}$/)
    expect(invoice_customer.legal_name).to match(/^LegalName #{suffix_regex}$/)
    expect(invoice_customer.legal_number).to be_present
    expect(invoice_customer.logo_url).to be_nil
    expect(invoice_customer.metadata).to eq []
    expect(invoice_customer.name).to match(/^Name \| #{suffix_regex}$/)
    expect(invoice_customer.net_payment_term).to be_nil
    expect(invoice_customer.phone).to eq '0601020304'
    expect(invoice_customer.sequential_id).to be_present
    expect(invoice_customer.skip_invoice_custom_sections).to be false
    expect(invoice_customer.slug).to be_present
    expect(invoice_customer.state).to be_present
    expect(invoice_customer.tax_identification_number).to be_nil
    expect(invoice_customer.timezone).to be_nil.or(be_present)
    expect(invoice_customer.updated_at).to be_present
    expect(invoice_customer.url).to be_nil
    expect(invoice_customer.zipcode).to be_present

    customer_shipping_address = customer.shipping_address
    expect(customer_shipping_address).to be_present
    expect(customer_shipping_address.address_line1).to be_nil
    expect(customer_shipping_address.address_line2).to be_nil
    expect(customer_shipping_address.city).to be_nil
    expect(customer_shipping_address.zipcode).to be_nil
    expect(customer_shipping_address.state).to be_nil
    expect(customer_shipping_address.country).to be_nil

    customer_billing_configuration = customer.billing_configuration
    expect(customer_billing_configuration).to be_present
    expect(customer_billing_configuration.invoice_grace_period).to be_nil
    expect(customer_billing_configuration.payment_provider).to be_nil
    expect(customer_billing_configuration.payment_provider_code).to be_nil
    expect(customer_billing_configuration.document_locale).to be_nil
  end

  def assert_one_off_invoice_attributes(invoice, customer = self.customer, skip: [])
    expect(invoice.applied_invoice_custom_sections).to eq [] unless skip.include?(:applied_invoice_custom_sections)
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
    expect(invoice.file_url).to be_nil
    expect(invoice.invoice_type).to eq 'one_off'
    expect(invoice.issuing_date).to eq Date.today.iso8601
    expect(invoice.lago_id).to be_present
    expect(invoice.metadata).to eq [] unless skip.include?(:metadata)
    expect(invoice.net_payment_term).to eq 0
    expect(invoice.number).to be_present
    expect(invoice.payment_dispute_lost_at).to be_nil
    expect(invoice.payment_due_date).to eq Date.today.iso8601
    expect(invoice.payment_overdue).to be false
    expect(invoice.payment_status).to eq 'pending' unless skip.include?(:payment_status)
    expect(invoice.prepaid_credit_amount_cents).to eq 0
    expect(invoice.progressive_billing_credit_amount_cents).to eq 0
    expect(invoice.self_billed).to be false
    expect(invoice.sequential_id).to be_present
    expect(invoice.status).to eq 'finalized'
    expect(invoice.sub_total_excluding_taxes_amount_cents).to eq 1000
    expect(invoice.sub_total_including_taxes_amount_cents).to eq 1000
    expect(invoice.subscriptions).to eq []
    expect(invoice.taxes_amount_cents).to eq 0
    expect(invoice.total_amount_cents).to eq 1000
    expect(invoice.total_due_amount_cents).to eq 1000
    expect(invoice.updated_at).to be_present
    expect(invoice.version_number).to eq 4
    expect(invoice.voided_at).to be_nil
    expect(invoice.xml_url).to be_nil

    fees = invoice.fees
    expect(fees.length).to eq 1

    fee = fees.first
    expect(fee.amount_cents).to eq 1000
    expect(fee.amount_currency).to eq 'USD'
    expect(fee.amount_details.to_h).to eq({})
    expect(fee.created_at).to be_present
    expect(fee.description).to eq "Test Fee #{customer_unique_id(customer)}"
    expect(fee.events_count).to be_nil
    expect(fee.external_customer_id).to be_nil
    expect(fee.external_subscription_id).to be_nil
    expect(fee.failed_at).to be_nil
    expect(fee.from_date).to be_present
    expect(fee.invoiceable).to be true
    expect(fee.lago_charge_filter_id).to be_nil
    expect(fee.lago_charge_id).to be_nil
    expect(fee.lago_customer_id).to be_nil
    expect(fee.lago_id).to be_present
    expect(fee.lago_invoice_id).to eq invoice.lago_id
    expect(fee.lago_subscription_id).to be_nil
    expect(fee.lago_true_up_fee_id).to be_nil
    expect(fee.lago_true_up_parent_fee_id).to be_nil
    expect(fee.pay_in_advance).to be false
    expect(fee.payment_status).to be_present
    expect(fee.precise_amount).to eq '10.0'
    expect(fee.precise_coupons_amount_cents).to eq '0.0'
    expect(fee.precise_total_amount).to eq '10.0'
    expect(fee.precise_unit_amount).to eq '10.0'
    expect(fee.pricing_unit_details).to be_nil
    expect(fee.refunded_at).to be_nil
    expect(fee.self_billed).to be false
    expect(fee.succeeded_at).to be_nil
    expect(fee.taxes_amount_cents).to eq 0
    expect(fee.taxes_precise_amount).to eq '0.0'
    expect(fee.taxes_rate).to eq 0.0
    expect(fee.to_date).to be_present
    expect(fee.total_aggregated_units).to be_nil
    expect(fee.total_amount_cents).to eq 1000
    expect(fee.total_amount_currency).to eq 'USD'
    expect(fee.units).to eq '1.0'

    fee_item = fee.item
    expect(fee_item.code).to eq add_on.code
    expect(fee_item.description).to be_nil
    expect(fee_item.filter_invoice_display_name).to be_nil
    expect(fee_item.filters).to be_nil
    expect(fee_item.grouped_by.to_h).to eq({})
    expect(fee_item.invoice_display_name).to eq "Test Fee #{customer_unique_id(customer)}"
    expect(fee_item.item_type).to eq 'AddOn'
    expect(fee_item.lago_item_id).to eq add_on.lago_id
    expect(fee_item.name).to eq add_on.name
    expect(fee_item.type).to eq 'add_on'

    assert_invoice_customer_attributes(invoice, customer)
  end

  describe '#create' do
    it 'creates a one-off invoice' do
      invoice = create_one_off_invoice

      assert_one_off_invoice_attributes(invoice)
    end
  end

  describe '#get' do
    let(:invoice_id) { create_one_off_invoice.lago_id }

    it 'gets a one-off invoice' do
      invoice = client.invoices.get(invoice_id)

      assert_one_off_invoice_attributes(invoice)
    end
  end

  describe '#get_all' do
    before_all_integration_tests do
      @other_customer = create_customer(presets: [:french, :with_searchable_attributes])
      @other_customer_invoice = create_one_off_invoice(customer: other_customer)

      @invoice1 = create_one_off_invoice(
        fees: [
          {
            add_on_code: add_on.code,
            unit_amount_cents: 500,
            units: 1,
            description: "Test Fee #{customer_unique_id(customer)} - 1",
            invoice_display_name: "Test Fee #{customer_unique_id(customer)} - 1",
          },
        ],
      )
      @invoice2 = create_one_off_invoice(
        fees: [
          {
            add_on_code: add_on.code,
            unit_amount_cents: 3000,
            units: 1,
            description: "Test Fee #{customer_unique_id(customer)} - 2",
            invoice_display_name: "Test Fee #{customer_unique_id(customer)} - 2",
          },
        ],
      )
      client.invoices.update(
        {
          metadata: [{ key: 'test', value: 'test' }],
          payment_status: 'succeeded',
        },
        invoice2.lago_id,
      )
    end

    attr_reader :other_customer, :other_customer_invoice, :invoice1, :invoice2

    def assert_get_all_invoices_attributes(invoice, customer, skip: [])
      expect(invoice.lago_id).to be_present
      expect(invoice.billing_entity_code).to eq 'hooli'
      expect(invoice.sequential_id).to be_present
      expect(invoice.number).to be_present
      expect(invoice.issuing_date).to eq Date.today.iso8601
      expect(invoice.payment_due_date).to eq Date.today.iso8601
      expect(invoice.net_payment_term).to eq 0
      expect(invoice.invoice_type).to eq 'one_off'
      expect(invoice.status).to eq 'finalized'
      expect(invoice.payment_status).to be_present
      expect(invoice.payment_dispute_lost_at).to be_nil
      expect(invoice.payment_overdue).to be false
      expect(invoice.currency).to eq(customer.currency)
      expect(invoice.fees_amount_cents).to be_present
      expect(invoice.taxes_amount_cents).to eq 0
      expect(invoice.progressive_billing_credit_amount_cents).to eq 0
      expect(invoice.coupons_amount_cents).to eq 0
      expect(invoice.credit_notes_amount_cents).to eq 0
      expect(invoice.sub_total_excluding_taxes_amount_cents).to be_present
      expect(invoice.sub_total_including_taxes_amount_cents).to be_present
      expect(invoice.total_amount_cents).to be_present
      expect(invoice.total_due_amount_cents).to be_present
      expect(invoice.prepaid_credit_amount_cents).to eq 0
      expect(invoice.file_url).to be_nil
      expect(invoice.xml_url).to be_nil
      expect(invoice.version_number).to eq 4
      expect(invoice.self_billed).to be false
      expect(invoice.created_at).to be_present
      expect(invoice.updated_at).to be_present
      expect(invoice.voided_at).to be_nil
      expect(invoice.metadata).to eq [] unless skip.include?(:metadata)
      expect(invoice.applied_taxes).to eq []

      assert_invoice_customer_attributes(invoice, customer)
    end

    def test_filtered_invoices(invoice, query_params)
      result = client.invoices.get_all(query_params)

      meta = result.meta
      expect(meta.current_page).to eq 1
      expect(meta.next_page).to be_nil
      expect(meta.prev_page).to be_nil
      expect(meta.total_count).to eq 1
      expect(meta.total_pages).to eq 1

      expect(result.invoices.length).to eq 1
      expect(result.invoices.first.lago_id).to eq invoice.lago_id
    end

    it 'gets all one-off invoices' do
      result = client.invoices.get_all

      meta = result.meta
      expect(meta.current_page).to eq 1
      expect(meta.next_page).to eq(2).or(be_nil)
      expect(meta.prev_page).to be_nil
      expect(meta.total_count).to be >= 3
      expect(meta.total_pages).to be >= 1

      invoices = result.invoices
      expect(invoices.length).to be >= 3

      first_invoice, second_invoice, third_invoice = invoices[..2]

      expect(first_invoice.lago_id).to eq invoice2.lago_id
      expect(second_invoice.lago_id).to eq invoice1.lago_id
      expect(third_invoice.lago_id).to eq other_customer_invoice.lago_id

      assert_get_all_invoices_attributes(first_invoice, customer, skip: [:metadata])
      first_invoice_metadata = first_invoice.metadata
      expect(first_invoice_metadata.length).to eq 1
      expect(first_invoice_metadata.first.key).to eq 'test'
      expect(first_invoice_metadata.first.value).to eq 'test'
      expect(first_invoice_metadata.first.lago_id).to be_present
      expect(first_invoice_metadata.first.created_at).to be_present

      assert_get_all_invoices_attributes(second_invoice, customer)
      assert_get_all_invoices_attributes(third_invoice, other_customer)
    end

    context 'when paginating' do
      it 'gets all one-off invoices for a customer' do
        result = client.invoices.get_all(page: 2, per_page: 1)

        meta = result.meta
        expect(meta.current_page).to eq 2
        expect(meta.next_page).to eq 3
        expect(meta.prev_page).to eq 1
        expect(meta.total_count).to be >= 3
        expect(meta.total_pages).to be >= 3

        expect(result.invoices.length).to eq 1
        expect(result.invoices.first.lago_id).to eq invoice1.lago_id
      end
    end

    context 'when filtering by customer_external_id' do
      it 'gets all one-off invoices for a customer' do
        test_filtered_invoices(other_customer_invoice, { customer_external_id: other_customer.external_id })
      end
    end

    context 'when filtering by external_customer_id' do
      it 'gets all one-off invoices for a customer' do
        test_filtered_invoices(other_customer_invoice, { external_customer_id: other_customer.external_id })
      end
    end

    context 'when filtering by amount_to' do
      it 'gets all one-off invoices for a customer' do
        test_filtered_invoices(invoice1, { external_customer_id: customer.external_id, amount_to: 500 })
      end
    end

    context 'when filtering by amount_from' do
      it 'gets all one-off invoices for a customer' do
        test_filtered_invoices(invoice2, { external_customer_id: customer.external_id, amount_from: 3000 })
      end
    end

    context 'when filtering by currency' do
      it 'gets all one-off invoices for a customer' do
        result = client.invoices.get_all(currency: 'USD')

        invoice_ids = result.invoices.map(&:lago_id)
        expect(invoice_ids).to include(invoice1.lago_id, invoice2.lago_id)
        expect(invoice_ids).not_to include(other_customer_invoice.lago_id)
      end
    end

    context 'when filtering by metadata' do
      it 'gets all one-off invoices for a customer' do
        test_filtered_invoices(
          invoice2,
          {
            external_customer_id: customer.external_id,
            'metadata[test]' => 'test',
          },
        )
      end
    end

    context 'when filtering by payment_status' do
      it 'gets all one-off invoices for a customer' do
        test_filtered_invoices(invoice2, { external_customer_id: customer.external_id, payment_status: 'succeeded' })
      end
    end
  end

  describe '#update' do
    let(:invoice_id) { create_one_off_invoice.lago_id }

    def assert_metadata_attributes(metadata, key, value)
      expect(metadata.key).to eq key
      expect(metadata.value).to eq value
      expect(metadata.lago_id).to be_present
      expect(metadata.created_at).to be_present
    end

    it 'updates a one-off invoice' do
      invoice = client.invoices.update(
        {
          payment_status: 'succeeded',
          metadata: [
            {
              key: 'meta1',
              value: 'value1',
            },
            {
              key: 'meta2',
              value: 'value2',
            },
          ],
        },
        invoice_id,
      )

      assert_one_off_invoice_attributes(invoice, skip: [:payment_status, :metadata])

      expect(invoice.payment_status).to eq 'succeeded'
      expect(invoice.metadata.length).to eq 2

      metadata = invoice.metadata.sort_by { |m| m[:key] }
      assert_metadata_attributes(metadata[0], 'meta1', 'value1')
      assert_metadata_attributes(metadata[1], 'meta2', 'value2')

      invoice = client.invoices.update(
        {
          metadata: [
            {
              id: metadata[0].lago_id,
              key: 'meta1',
              value: 'value1-updated',
            },
            {
              key: 'meta3',
              value: 'value3',
            },
          ],
        },
        invoice_id,
      )

      expect(invoice.metadata.length).to eq 2

      metadata = invoice.metadata.sort_by { |m| m[:key] }
      assert_metadata_attributes(metadata[0], 'meta1', 'value1-updated')
      assert_metadata_attributes(metadata[1], 'meta3', 'value3')

      invoice = client.invoices.update({ metadata: [] }, invoice_id)
      expect(invoice.metadata.length).to eq 0
    end
  end
end
