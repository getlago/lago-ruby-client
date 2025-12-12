# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#customers', :integration do
  describe '#create' do
    it 'creates and upserts a customer' do
      customer = create_customer(
        params: {
          address_line1: '123 Main St',
          address_line2: 'Apt 1',
          city: 'London',
          country: 'GB',
          currency: 'GBP',
          customer_type: 'company',
          external_salesforce_id: 'salesforce-id-123',
          legal_number: '1234567890',
          logo_url: 'https://example.com/logo.png',
          metadata: [{ key: 'is_synced', value: 'false' }],
          net_payment_term: 10,
          phone: '+1234567890',
          state: 'London',
          tax_identification_number: '1234567890',
          url: 'https://example.com',
          zipcode: 'SW1A 1AA',
          shipping_address: {
            address_line1: '124 Main St',
            address_line2: 'Apt 2',
            city: 'New York',
            country: 'US',
            state: 'NY',
            zipcode: '10001',
          },
          billing_configuration: {
            document_locale: 'de',
          },
        },
        presets: [:with_searchable_attributes],
      )

      fetched_customer = client.customers.get(customer.external_id)

      [customer, fetched_customer].each do |c|
        expect(c.account_type).to eq 'customer'
        expect(c.address_line1).to eq '123 Main St'
        expect(c.address_line2).to eq 'Apt 1'
        expect(c.applicable_invoice_custom_sections).to eq []
        expect(c.applicable_timezone).to be_present
        expect(c.billing_entity_code).to eq 'hooli'
        expect(c.city).to eq 'London'
        expect(c.country).to eq 'GB'
        expect(c.created_at).not_to be_nil
        expect(c.currency).to eq 'GBP'
        expect(c.customer_type).to eq 'company'
        expect(c.email).to match(/^yohan\+ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}@getlago\.com$/)
        expect(c.external_id).to match(/^ExternalID ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
        expect(c.external_salesforce_id).to be_nil # TODO: fix this
        expect(c.finalize_zero_amount_invoice).to eq 'inherit'
        expect(c.firstname).to match(/^Firstname ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
        expect(c.integration_customers).to eq []
        expect(c.lago_id).not_to be_nil
        expect(c.lastname).to match(/^Lastname ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
        expect(c.legal_name).to match(/^LegalName ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
        expect(c.legal_number).to eq '1234567890'
        expect(c.logo_url).to eq 'https://example.com/logo.png'
        expect(c.name).to match(/^Name \| ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
        expect(c.net_payment_term).to eq 10
        expect(c.phone).to eq '+1234567890'
        expect(c.sequential_id).to be_a(Integer)
        expect(c.skip_invoice_custom_sections).to be false
        expect(c.slug).to match(/^HOO-\w{4}-\d{3}$/)
        expect(c.state).to eq 'London'
        expect(c.tax_identification_number).to eq '1234567890'
        expect(c.taxes).to eq []
        expect(c.timezone).to be_nil # premium feature
        expect(c.updated_at).not_to be_nil
        expect(c.url).to eq 'https://example.com'
        expect(c.zipcode).to eq 'SW1A 1AA'

        shipping_address = c.shipping_address
        expect(shipping_address.address_line1).to eq '124 Main St'
        expect(shipping_address.address_line2).to eq 'Apt 2'
        expect(shipping_address.city).to eq 'New York'
        expect(shipping_address.country).to eq 'US'
        expect(shipping_address.state).to eq 'NY'
        expect(shipping_address.zipcode).to eq '10001'

        billing_configuration = c.billing_configuration
        expect(billing_configuration.invoice_grace_period).to be_nil # premium feature
        expect(billing_configuration.payment_provider).to be_nil
        expect(billing_configuration.payment_provider_code).to be_nil
        expect(billing_configuration.document_locale).to eq 'de'

        metadata = c.metadata
        expect(metadata.count).to eq 1

        first_metadata = metadata.first
        expect(first_metadata.key).to eq 'is_synced'
        expect(first_metadata.value).to eq 'false'
        expect(first_metadata.display_in_invoice).to be false
        expect(first_metadata.created_at).not_to be_nil
        expect(first_metadata.lago_id).not_to be_nil
      end

      updated_customer = client.customers.create(
        external_id: customer.external_id,
        address_line1: '133 Main St',
        address_line2: 'Apt 3',
        shipping_address: {
          address_line1: '134 Main St',
          address_line2: 'Apt 4',
        },
      )

      expect(updated_customer.lago_id).to eq customer.lago_id

      fetched_updated_customer = client.customers.get(updated_customer.external_id)

      [updated_customer, fetched_updated_customer].each do |c|
        expect(c.address_line1).to eq '133 Main St'
        expect(c.address_line2).to eq 'Apt 3'
        expect(c.shipping_address.address_line1).to eq '134 Main St'
        expect(c.shipping_address.address_line2).to eq 'Apt 4'
      end
    end
  end

  describe '#get_all' do
    context 'without filters' do
      before_all_integration_tests do
        @us_customer = create_customer(
          params: {
            tax_identification_number: 'US1234567890',
            customer_type: 'company',
            metadata: [{ key: 'is_synced', value: 'false' }],
          },
          presets: [:us, :with_searchable_attributes],
        )
        @fr_customer = create_customer(
          params: {
            metadata: [
              { key: 'is_synced', value: 'true' },
              { key: 'last_synced_at', value: '2025-01-01' },
            ],
          },
          presets: [:french, :with_searchable_attributes],
        )

        @gb_customer = create_customer(
          params: {
            country: 'GB',
            state: 'London',
            zipcode: 'SW1A 1AA',
            currency: 'GBP',
          },
          presets: [:with_searchable_attributes],
        )
      end

      attr_reader :us_customer, :fr_customer, :gb_customer

      def suffix
        us_customer.name.split(' ').last
      end

      def all_customers
        [us_customer, fr_customer, gb_customer]
      end

      def get_all_customers(params = {})
        params = { page: 1, per_page: 1 }.merge(params)
        result = client.customers.get_all(params)
        result.customers
      end

      def test_filtered_customers(expected_customers, params = {})
        expected_customers = Array(expected_customers)
        expected_customer_count = expected_customers.count
        # We fetch one more customer than expected to ensure we properly filter out the customers.
        per_page = expected_customer_count + 1
        params = params.merge(per_page:, page: 1)
        fetched_customers = get_all_customers(params)
        expect(fetched_customers.count).to be >= expected_customer_count
        expect(fetched_customers.take(expected_customer_count).map(&:lago_id)).to eq(expected_customers.map(&:lago_id))

        if fetched_customers.count == expected_customer_count
          # This is the first time we're running the test group, so we expect to find only the customers we expect.
          return
        end

        # We've ran the test group multiple times so there might be older customers from previous tests.
        # We just ensure that the other customers from this test run are properly filtered out.
        other_customers = all_customers - expected_customers
        expect(other_customers.map(&:lago_id)).not_to include(fetched_customers.last.lago_id)
      end

      it 'returns all customers' do
        response = client.customers.get_all({ per_page: 3 })

        meta = response.meta
        expect(meta.total_count).to be >= 3
        expect(meta.current_page).to eq(1)
        expect(meta.prev_page).to be_nil
        expect(meta.total_pages).to be >= 1

        customers = response.customers
        expect(customers.count).to be >= 3
        first_customer = customers.first
        expect(first_customer.lago_id).not_to be_nil
        expect(first_customer.external_id).to match(/^ExternalID #{unique_id_regex}$/)
        expect(first_customer.name).to match(/^Name \| #{unique_id_regex}$/)
        expect(first_customer.firstname).to match(/^Firstname #{unique_id_regex}$/)
        expect(first_customer.lastname).to match(/^Lastname #{unique_id_regex}$/)
        expect(first_customer.email).to match(/^yohan\+#{unique_id_regex}@getlago\.com$/)
        expect(first_customer.country).to eq('GB')
        expect(first_customer.state).to eq('London')
        expect(first_customer.zipcode).to eq('SW1A 1AA')
        expect(first_customer.currency).to eq('GBP')
        expect(first_customer.legal_name).to match(/^LegalName #{unique_id_regex}$/)
        expect(first_customer.legal_number).to be_nil
        expect(first_customer.customer_type).to be_nil
        expect(first_customer.tax_identification_number).to be_nil
        expect(first_customer.metadata).to eq []
        expect(first_customer.created_at).not_to be_nil
        expect(first_customer.updated_at).not_to be_nil

        second_customer = customers[1]
        expect(second_customer.lago_id).not_to be_nil
        expect(second_customer.external_id).to match(/^ExternalID #{unique_id_regex}$/)
        expect(second_customer.name).to match(/^Name \| #{unique_id_regex}$/)
        expect(second_customer.firstname).to match(/^Firstname #{unique_id_regex}$/)
        expect(second_customer.lastname).to match(/^Lastname #{unique_id_regex}$/)
        expect(second_customer.email).to match(/^yohan\+#{unique_id_regex}@getlago\.com$/)
        expect(second_customer.country).to eq('FR')
        expect(second_customer.state).to eq('Paris')
        expect(second_customer.zipcode).to eq('75001')
        expect(second_customer.currency).to eq('EUR')
        expect(second_customer.legal_name).to match(/^LegalName #{unique_id_regex}$/)
        expect(second_customer.legal_number).to match(/^FR1234567890$/)
        expect(second_customer.customer_type).to be_nil
        expect(second_customer.tax_identification_number).to be_nil
        expect(second_customer.metadata).not_to be_nil
        expect(second_customer.metadata.first.key).to eq('is_synced')
        expect(second_customer.metadata.first.value).to eq('true')
        expect(second_customer.metadata.last.key).to eq('last_synced_at')
        expect(second_customer.metadata.last.value).to eq('2025-01-01')
        expect(second_customer.created_at).not_to be_nil
        expect(second_customer.updated_at).not_to be_nil

        third_customer = customers[2]
        expect(third_customer.lago_id).not_to be_nil
        expect(third_customer.external_id).to match(/^ExternalID #{unique_id_regex}$/)
        expect(third_customer.name).to match(/^Name \| #{unique_id_regex}$/)
        expect(third_customer.firstname).to match(/^Firstname #{unique_id_regex}$/)
        expect(third_customer.lastname).to match(/^Lastname #{unique_id_regex}$/)
        expect(third_customer.email).to match(/^yohan\+#{unique_id_regex}@getlago\.com$/)
        expect(third_customer.country).to eq('US')
        expect(third_customer.state).to eq('CA')
        expect(third_customer.zipcode).to eq('94101')
        expect(third_customer.currency).to eq('USD')
        expect(third_customer.legal_name).to match(/^LegalName #{unique_id_regex}$/)
        expect(third_customer.legal_number).to match(/^US1234567890$/)
        expect(third_customer.customer_type).to eq('company')
        expect(third_customer.tax_identification_number).to eq('US1234567890')
        expect(third_customer.metadata).not_to be_nil
        expect(third_customer.metadata.first.key).to eq('is_synced')
        expect(third_customer.metadata.first.value).to eq('false')
        expect(third_customer.created_at).not_to be_nil
        expect(third_customer.updated_at).not_to be_nil
      end

      context 'when paginating' do
        it 'returns the customers with the given page and per_page' do
          [gb_customer, fr_customer, us_customer].each_with_index do |customer, index|
            params = { page: index + 1, per_page: 1 }
            customers = get_all_customers(params)
            expect(customers.count).to eq(1)
            expect(customers.first.lago_id).to eq(customer.lago_id)
          end
        end
      end

      context 'when filtering by name' do
        it 'returns the customers with the given name' do
          test_filtered_customers(us_customer, { search_term: "e | #{suffix}" })
        end
      end

      context 'when filtering by firstname' do
        it 'returns the customers with the given firstname' do
          test_filtered_customers(us_customer, { search_term: "rstname #{suffix}" })
        end
      end

      context 'when filtering by lastname' do
        it 'returns the customers with the given lastname' do
          test_filtered_customers(us_customer, { search_term: "astname #{suffix}" })
        end
      end

      context 'when filtering by legalname' do
        it 'returns the customers with the given legalname' do
          test_filtered_customers(us_customer, { search_term: "egalname #{suffix}" })
        end
      end

      context 'when filtering by externalid' do
        it 'returns the customers with the given externalid' do
          test_filtered_customers(us_customer, { search_term: "ID #{suffix}" })
        end
      end

      context 'when filtering by email' do
        it 'returns the customers with the given email' do
          test_filtered_customers(us_customer, { search_term: "n+#{suffix}@getlago.com" })
        end
      end

      context 'when filtering by country' do
        it 'returns the customers with the given country' do
          test_filtered_customers(us_customer, { 'countries[]': ['US'] })

          test_filtered_customers([fr_customer, us_customer], { 'countries[]': %w[US FR] })
        end
      end

      context 'when filtering by state' do
        it 'returns the customers with the given state' do
          test_filtered_customers(us_customer, { 'states[]': ['CA'] })

          test_filtered_customers([fr_customer, us_customer], { 'states[]': %w[CA Paris] })
        end
      end

      context 'when filtering by zipcode' do
        it 'returns the customers with the given zipcode' do
          test_filtered_customers(us_customer, { 'zipcodes[]': ['94101'] })

          test_filtered_customers([fr_customer, us_customer], { 'zipcodes[]': %w[94101 75001] })
        end
      end

      context 'when filtering by currency' do
        it 'returns the customers with the given currency' do
          test_filtered_customers(us_customer, { 'currencies[]': ['USD'] })

          test_filtered_customers([fr_customer, us_customer], { 'currencies[]': %w[USD EUR] })
        end
      end

      context 'when filtering by customer_type' do
        it 'returns the customers with the given customer_type' do
          test_filtered_customers(us_customer, { customer_type: 'company' })
        end
      end

      context 'when filtering by has_customer_type' do
        it 'returns the customers with the given has_customer_type' do
          test_filtered_customers(us_customer, { has_customer_type: 'true' })

          test_filtered_customers([gb_customer, fr_customer], { has_customer_type: 'false' })
        end
      end

      context 'when filtering by has_tax_identification_number' do
        it 'returns the customers with the given has_tax_identification_number' do
          test_filtered_customers(us_customer, { has_tax_identification_number: 'true' })

          test_filtered_customers([gb_customer, fr_customer], { has_tax_identification_number: 'false' })
        end
      end

      context 'when filtering by metadata' do
        def params_with_metadata(per_page: 1, page: 1, **metadata)
          metadata.transform_keys { |key| "metadata[#{key}]" }.merge(per_page:, page:)
        end

        it 'returns the customers with the given metadata' do
          test_filtered_customers(us_customer, params_with_metadata(is_synced: 'false'))

          test_filtered_customers(
            fr_customer,
            params_with_metadata(is_synced: 'true'),
          )

          test_filtered_customers(
            fr_customer,
            params_with_metadata(is_synced: 'true', last_synced_at: '2025-01-01'),
          )

          test_filtered_customers(
            fr_customer,
            params_with_metadata(
              is_synced: 'true',
              last_synced_at: '2025-01-01',
              first_synced_at: '',
            ),
          )

          test_filtered_customers(
            [gb_customer, us_customer],
            params_with_metadata(last_synced_at: ''),
          )
        end
      end
    end
  end
end
