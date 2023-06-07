# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Customer do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:factory_customer) { FactoryBot.build(:customer) }

  let(:response) do
    {
      'customer' => {
        'external_id' => factory_customer.external_id,
        'name' => factory_customer.name,
        'country' => factory_customer.country,
        'address_line1' => factory_customer.address_line1,
        'address_line2' => factory_customer.address_line2,
        'state' => factory_customer.state,
        'zipcode' => factory_customer.zipcode,
        'email' => factory_customer.email,
        'city' => factory_customer.city,
        'url' => factory_customer.url,
        'phone' => factory_customer.phone,
        'logo_url' => factory_customer.logo_url,
        'legal_name' => factory_customer.legal_name,
        'legal_number' => factory_customer.legal_number,
        'tax_identification_number' => factory_customer.tax_identification_number,
        'currency' => factory_customer.currency,
        'timezone' => factory_customer.timezone,
      },
    }.to_json
  end

  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#create' do
    let(:params) { factory_customer.to_h }
    let(:body) do
      {
        'customer' => factory_customer.to_h,
      }
    end

    context 'when customer is successfully created or found' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/customers')
          .with(body: body)
          .to_return(body: body.to_json, status: 200)
      end

      it 'returns customer' do
        customer = resource.create(params)

        expect(customer.external_id).to eq(factory_customer.external_id)
        expect(customer.name).to eq(factory_customer.name)
        expect(customer.currency).to eq(factory_customer.currency)
        expect(customer.tax_identification_number).to eq(factory_customer.tax_identification_number)
        expect(customer.billing_configuration.invoice_grace_period).to eq(factory_customer.billing_configuration[:invoice_grace_period])
        expect(customer.billing_configuration.provider_customer_id).to eq(factory_customer.billing_configuration[:provider_customer_id])
        expect(customer.metadata.first.key).to eq(factory_customer.metadata.first[:key])
        expect(customer.metadata.first.value).to eq(factory_customer.metadata.first[:value])
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
          .with(body: body)
          .to_return(body: response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#current_usage' do
    let(:factory_customer_usage) { FactoryBot.build(:customer_usage) }

    context 'when the customer exists' do
      before do
        usage_json = JSON.generate('customer_usage' => factory_customer_usage.to_h)

        stub_request(:get, 'https://api.getlago.com/api/v1/customers/external_customer_id/current_usage?external_subscription_id=123')
          .to_return(body: usage_json, status: 200)
      end

      it 'returns the usage of the customer' do
        response = resource.current_usage('external_customer_id', '123')

        expect(response['customer_usage']['from_date']).to eq(factory_customer_usage.from_date)
      end
    end

    context 'when the customer does not exists' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/customers/DOESNOTEXIST/current_usage?external_subscription_id=123')
          .to_return(body: JSON.generate(status: 404, error: 'Not Found'), status: 404)
      end

      it 'raises an error' do
        expect { resource.current_usage('DOESNOTEXIST', '123') }.to raise_error Lago::Api::HttpError
      end
    end

    context 'when the customer does not have a subscription' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/customers/NOSUBSCRIPTION/current_usage?external_subscription_id=123')
          .to_return(body: JSON.generate(status: 422, error: 'no_active_subscription'), status: 422)
      end

      it 'raises an error' do
        expect { resource.current_usage('DOESNOTEXIST', '123') }.to raise_error
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
              'jM2NloiLCJwdXIiOm51bGx9fQ==--7128c6e541adc7b4c14249b1b18509f92e652d17'
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
        stub_request(:delete, "https://api.getlago.com/api/v1/customers/#{factory_customer.external_id}")
          .to_return(body: response, status: 200)
      end

      it 'returns a customer' do
        customer = resource.destroy(factory_customer.external_id)

        expect(customer.external_id).to eq(factory_customer.external_id)
        expect(customer.name).to eq(factory_customer.name)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/customers/#{factory_customer.external_id}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy(factory_customer.external_id) }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
