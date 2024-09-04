# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Customer do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:customer_external_id) { JSON.parse(customer_response)['customer']['external_id'] }
  let(:customer_response) { load_fixture(:customer) }

  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#create' do
    let(:params) { create(:create_customer).to_h }

    context 'when customer is successfully created or found' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/customers')
          .with(body: { customer: params })
          .to_return(body: customer_response, status: 200)
      end

      it 'returns customer' do
        pp params
        customer = resource.create(params)

        pp customer

        expect(customer.external_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
        expect(customer.name).to eq('Gavin Belson')
        expect(customer.currency).to eq('EUR')
        expect(customer.net_payment_term).to eq(nil)
        expect(customer.tax_identification_number).to eq('EU123456789')
        expect(customer.billing_configuration.invoice_grace_period).to eq(3)
        expect(customer.billing_configuration.provider_customer_id).to eq('cus_12345')
        expect(customer.billing_configuration.provider_payment_methods).to eq(['card'])
        expect(customer.shipping_address.city).to eq('Woodland Hills')
        expect(customer.shipping_address.country).to eq('US')
        expect(customer.integration_customers.first.external_customer_id).to eq('123456789')
        expect(customer.integration_customers.first.type).to eq('netsuite')
        expect(customer.metadata.first.key).to eq('key')
        expect(customer.metadata.first.value).to eq('value')
        expect(customer.taxes.map(&:code)).to eq(['tax_code'])
      end
    end

    context 'when customer is NOT successfully created' do
      let(:response) do
        {
          'status' => 422,
          'error' => 'Unprocessable Entity',
          'message' => 'Validation error on the record',
        }.to_json
      end

      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/customers')
          .with(body: { customer: params })
          .to_return(body: response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#current_usage' do
    let(:customer_usage_response) { load_fixture('customer_usage') }
    let(:subscription_external_id) { '123' }

    context 'when the customer exists' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{customer_external_id}/current_usage?external_subscription_id=#{subscription_external_id}")
          .to_return(body: customer_usage_response, status: 200)
      end

      it 'returns the usage of the customer' do
        response = resource.current_usage(customer_external_id, subscription_external_id)

        expect(response['customer_usage']['from_datetime']).to eq('2022-07-01T00:00:00Z')
      end
    end

    context 'when the customer does not exists' do
      let(:customer_external_id) { 'DOESNOTEXIST' }

      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{customer_external_id}/current_usage?external_subscription_id=#{subscription_external_id}")
          .to_return(body: JSON.generate(status: 404, error: 'Not Found'), status: 404)
      end

      it 'raises an error' do
        expect do
          resource.current_usage(customer_external_id, subscription_external_id)
        end.to raise_error(Lago::Api::HttpError)
      end
    end

    context 'when the customer does not have a subscription' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{customer_external_id}/current_usage?external_subscription_id=#{subscription_external_id}")
          .to_return(body: JSON.generate(status: 422, error: 'no_active_subscription'), status: 422)
      end

      it 'raises an error' do
        expect do
          resource.current_usage(customer_external_id, subscription_external_id)
        end.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#past_usage' do
    let(:customer_usage_response) { load_fixture('customer_past_usage') }
    let(:subscription_external_id) { '123' }

    context 'when the customer exists' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{customer_external_id}/past_usage?external_subscription_id=#{subscription_external_id}")
          .to_return(body: customer_usage_response, status: 200)
      end

      it 'returns the past usage of the customer' do
        response = resource.past_usage(customer_external_id, subscription_external_id)

        expect(response['usage_periods'].count).to eq(1)
        expect(response['usage_periods'].first['from_datetime']).to eq('2022-07-01T00:00:00Z')
      end
    end

    context 'with a filter on a billable metric code' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{customer_external_id}/past_usage?external_subscription_id=#{subscription_external_id}&billable_metric_code=bm_code")
          .to_return(body: customer_usage_response, status: 200)
      end

      it 'returns the past usage of the customer' do
        response = resource.past_usage(customer_external_id, subscription_external_id, billable_metric_code: 'bm_code')

        expect(response['usage_periods'].count).to eq(1)
        expect(response['usage_periods'].first['from_datetime']).to eq('2022-07-01T00:00:00Z')
      end
    end

    context 'when the customer does not exists' do
      let(:customer_external_id) { 'DOESNOTEXIST' }

      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{customer_external_id}/past_usage?external_subscription_id=#{subscription_external_id}")
          .to_return(body: JSON.generate(status: 404, error: 'Not Found'), status: 404)
      end

      it 'raises an error' do
        expect do
          resource.past_usage(customer_external_id, subscription_external_id)
        end.to raise_error(Lago::Api::HttpError)
      end
    end

    context 'when the customer does not have a subscription' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{customer_external_id}/past_usage?external_subscription_id=#{subscription_external_id}")
          .to_return(body: JSON.generate(status: 422, error: 'no_active_subscription'), status: 422)
      end

      it 'raises an error' do
        expect do
          resource.past_usage(customer_external_id, subscription_external_id)
        end.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#plan_url' do
    context 'when the customer exists' do
      before do
        url_json = JSON.generate(
          'customer' => {
            'portal_url' =>
              'https://app.lago.dev/customer-portal/eyJfcmFpbHMiOnsibWVzc2FnZSI6IkJBaEpJaWt3WkdGbE1qWmx'\
              'ZUzFqWlRnekxUUTJZell0T1dRNFl5MHdabVF4TURabFlqY3dNVElHT2daRlZBPT0iLCJleHAiOiIyMDIzLTAzLTIzVDIzOjAzOjAwL'\
              'jM2NloiLCJwdXIiOm51bGx9fQ==--7128c6e541adc7b4c14249b1b18509f92e652d17',
          }
        )

        stub_request(:get, 'https://api.getlago.com/api/v1/customers/external_customer_id/portal_url')
          .to_return(body: url_json, status: 200)
      end

      it 'returns the customer portal url' do
        portal_url = resource.portal_url('external_customer_id')

        expect(portal_url).to include('https://app.lago.dev/customer-portal/')
      end
    end

    context 'when the customer does not exists' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/customers/DOESNOTEXIST/portal_url')
          .to_return(body: JSON.generate(status: 404, error: 'Not Found'), status: 404)
      end

      it 'raises an error' do
        expect { resource.portal_url('DOESNOTEXIST') }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#destroy' do
    context 'when customer is successfully destroyed' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/customers/#{customer_external_id}")
          .to_return(body: customer_response, status: 200)
      end

      it 'returns a customer' do
        customer = resource.destroy(customer_external_id)

        expect(customer.external_id).to eq(customer_external_id)
        expect(customer.name).to eq('Gavin Belson')
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/customers/#{customer_external_id}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy(customer_external_id) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#checkout_url' do
    let(:response_body) do
      {
        "customer": {
          "lago_customer_id": customer_external_id,
          "external_customer_id": "1a901a90-1a90-1a90-1a90-1a901a901a90",
          "payment_provider": "stripe",
          "checkout_url": "https://checkout.stripe.com/c/pay/foobar"
        }
      }.to_json
    end

    context 'when the customer exists' do
      before do
        # NOTE: Api makes POST to /customers endpoint first
        # stub_request(:post, "https://api.getlago.com/api/v1/customers/#{customer_external_id}/checkout_url")
        #   .to_return(body: response_body, status: 200)

        stub_request(:post, 'https://api.getlago.com/api/v1/customers')
          .to_return(body: response_body, status: 200)
      end

      it 'returns the checkout URL' do
        response = resource.checkout_url(customer_external_id)

        expect(response.checkout_url).to eq('https://checkout.stripe.com/c/pay/foobar')
        expect(response.lago_customer_id).to eq(customer_external_id)
        expect(response.external_customer_id).to eq("1a901a90-1a90-1a90-1a90-1a901a901a90")
        expect(response.payment_provider).to eq("stripe")
      end
    end

    context 'when the customer does not exists' do
      let(:customer_external_id) { 'DOESNOTEXIST' }

      before do
        # NOTE: Api makes POST to /customers endpoint first
        # stub_request(:post, "https://api.getlago.com/api/v1/customers/#{customer_external_id}/checkout_url")
        #   .to_return(body: JSON.generate(status: 404, error: 'Not Found'), status: 404)

        stub_request(:post, 'https://api.getlago.com/api/v1/customers')
          .to_return(body: JSON.generate(status: 404, error: 'Not Found'), status: 404)
      end

      it 'raises an error' do
        expect do
          resource.checkout_url(customer_external_id)
        end.to raise_error(Lago::Api::HttpError)
      end
    end
  end
end
