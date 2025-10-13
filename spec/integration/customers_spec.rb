# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#customers', :integration do
  describe '#get_all' do
    context 'without filters' do
      before_all_integration_tests do
        @us_customer = create_customer(
          params: {
            tax_identification_number: 'US1234567890',
            customer_type: 'company',
            metadata: [{ key: 'is_synced', value: 'false' }],
          },
          presets: [:us],
        )
        @fr_customer = create_customer(
          params: {
            metadata: [
              { key: 'is_synced', value: 'true' },
              { key: 'last_synced_at', value: '2025-01-01' },
            ],
          },
          presets: [:french],
        )

        @gb_customer = create_customer(
          params: {
            country: 'GB',
            state: 'London',
            zipcode: 'SW1A 1AA',
            currency: 'GBP',
          },
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
        expect(first_customer.external_id).to match(/^ExternalID ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
        expect(first_customer.name).to match(/^Name \| ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
        expect(first_customer.firstname).to match(/^Firstname ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
        expect(first_customer.lastname).to match(/^Lastname ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
        expect(first_customer.email).to match(/^yohan\+ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}@getlago\.com$/)
        expect(first_customer.country).to eq('GB')
        expect(first_customer.state).to eq('London')
        expect(first_customer.zipcode).to eq('SW1A 1AA')
        expect(first_customer.currency).to eq('GBP')
        expect(first_customer.legal_name).to match(/^LegalName ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
        expect(first_customer.legal_number).to be_nil
        expect(first_customer.customer_type).to be_nil
        expect(first_customer.tax_identification_number).to be_nil
        expect(first_customer.metadata).to eq []
        expect(first_customer.created_at).not_to be_nil
        expect(first_customer.updated_at).not_to be_nil

        second_customer = customers[1]
        expect(second_customer.lago_id).not_to be_nil
        expect(second_customer.external_id).to match(/^ExternalID ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
        expect(second_customer.name).to match(/^Name \| ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
        expect(second_customer.firstname).to match(/^Firstname ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
        expect(second_customer.lastname).to match(/^Lastname ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
        expect(second_customer.email).to match(/^yohan\+ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}@getlago\.com$/)
        expect(second_customer.country).to eq('FR')
        expect(second_customer.state).to eq('Paris')
        expect(second_customer.zipcode).to eq('75001')
        expect(second_customer.currency).to eq('EUR')
        expect(second_customer.legal_name).to match(/^LegalName ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
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
        expect(third_customer.external_id).to match(/^ExternalID ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
        expect(third_customer.name).to match(/^Name \| ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
        expect(third_customer.firstname).to match(/^Firstname ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
        expect(third_customer.lastname).to match(/^Lastname ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
        expect(third_customer.email).to match(/^yohan\+ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}@getlago\.com$/)
        expect(third_customer.country).to eq('US')
        expect(third_customer.state).to eq('CA')
        expect(third_customer.zipcode).to eq('94101')
        expect(third_customer.currency).to eq('USD')
        expect(third_customer.legal_name).to match(/^LegalName ruby-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}-\d{3}$/)
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
