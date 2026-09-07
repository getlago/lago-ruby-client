# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::PaymentFilters do
  let(:client) { Lago::Api::Client.new(api_key: 'test_key') }
  let(:response_body) { { payments: [], meta: { total_count: 0 } }.to_json }

  [false, true].each do |customer_scoped|
    context "with customer scope #{customer_scoped}" do
      let(:resource) do
        if customer_scoped
          Lago::Api::Resources::Customers::Payment.new(client, 'cust_1')
        else
          Lago::Api::Resources::Payment.new(client)
        end
      end
      let(:url) do
        path = customer_scoped ? 'customers/cust_1/payments' : 'payments'
        "https://api.getlago.com/api/v1/#{path}"
      end

      it 'encodes every filter including arrays, zero, int64 and punctuation without mutating options' do
        options = {
          page: 2,
          per_page: 5,
          invoice_id: '1a901a90-1a90-1a90-1a90-1a901a901a90',
          payment_status: %w[succeeded failed],
          payment_statuses: ['pending'],
          amount_from: 0,
          amount_to: 9_223_372_036_854_775_807,
          receipt_number: 'Rcpt & +/#1',
          created_at_from: '2026-09-01',
          created_at_to: '2026-09-07',
          payment_provider_type: %w[stripe gocardless],
          payment_method_type: %w[card sepa_debit],
          currency: 'EUR',
          invoice_number: 'LAG & +/#2',
          payment_type: %w[manual provider],
          payable_type: %w[Invoice PaymentRequest],
          search_term: 'pi_3 & +/#',
        }.freeze
        expected = {
          'page' => ['2'],
          'per_page' => ['5'],
          'invoice_id' => ['1a901a90-1a90-1a90-1a90-1a901a901a90'],
          'payment_status[]' => %w[succeeded failed],
          'payment_statuses[]' => ['pending'],
          'amount_from' => ['0'],
          'amount_to' => ['9223372036854775807'],
          'receipt_number' => ['Rcpt & +/#1'],
          'created_at_from' => ['2026-09-01'],
          'created_at_to' => ['2026-09-07'],
          'payment_provider_type[]' => %w[stripe gocardless],
          'payment_method_type[]' => %w[card sepa_debit],
          'currency' => ['EUR'],
          'invoice_number' => ['LAG & +/#2'],
          'payment_type[]' => %w[manual provider],
          'payable_type[]' => %w[Invoice PaymentRequest],
          'search_term' => ['pi_3 & +/#'],
        }
        request = stub_request(:get, /^#{Regexp.escape(url)}(?:\?|$)/).with do |actual|
          decoded = URI.decode_www_form(actual.uri.query).group_by(&:first).transform_values do |pairs|
            pairs.map(&:last)
          end
          decoded.transform_values(&:sort) == expected.transform_values(&:sort) &&
            actual.headers['Authorization'] == 'Bearer test_key'
        end.to_return(body: response_body)

        resource.get_all(options)

        expect(request).to have_been_requested
      end

      it 'preserves scalar values, string keys, explicit brackets and repeated query pairs' do
        options = [
          ['payment_status', 'processing'],
          ['payment_method_type[]', 'card'],
          ['payment_method_type[]', 'sepa_debit'],
          ['payment_type', []],
        ]
        request = stub_request(:get, /^#{Regexp.escape(url)}(?:\?|$)/).with do |actual|
          URI.decode_www_form(actual.uri.query).sort == [
            ['payment_status', 'processing'], ['payment_method_type[]', 'card'], ['payment_method_type[]', 'sepa_debit']
          ].sort
        end.to_return(body: response_body)

        resource.get_all(options)

        expect(request).to have_been_requested
      end
    end
  end
end
