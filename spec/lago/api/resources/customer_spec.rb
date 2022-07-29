# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Customer do
  subject(:resource) { described_class.new(client) }
  let(:client) { Lago::Api::Client.new }
  let(:factory_customer) { FactoryBot.build(:customer) }

  describe '#create' do
    let(:params) { factory_customer.to_h }
    let(:body) do
      {
        'customer' => factory_customer.to_h
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

        expect(customer.customer_id).to eq(factory_customer.customer_id)
        expect(customer.name).to eq(factory_customer.name)
        expect(customer.billing_configuration.provider_customer_id).to eq(factory_customer.billing_configuration[:provider_customer_id])
      end
    end

    context 'when customer is NOT successfully created' do
      let(:response) do
        {
          'status' => 422,
          'error' => 'Unprocessable Entity',
          'message' => 'Validation error on the record'
        }.to_json
      end

      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/customers')
          .with(body: body)
          .to_return(body: response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#current_usage' do
    let(:factory_customer_usage) { FactoryBot.build(:customer_usage) }

    context 'when the customer exists' do
      before do
        usage_json = JSON.generate('customer_usage' => factory_customer_usage.to_h)

        stub_request(:get, 'https://api.getlago.com/api/v1/customers/customer_id/current_usage?subscription_id=123')
          .to_return(body: usage_json, status: 200)
      end

      it 'returns the usage of the customer' do
        response = resource.current_usage('customer_id', '123')

        expect(response['customer_usage']['from_date']).to eq(factory_customer_usage.from_date)
      end
    end

    context 'when the customer does not exists' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/customers/DOESNOTEXIST/current_usage?subscription_id=123')
          .to_return(body: JSON.generate(status: 404, error: 'Not Found'), status: 404)
      end

      it 'raises an error' do
        expect { resource.current_usage('DOESNOTEXIST', '123') }.to raise_error
      end
    end

    context 'when the customer does not have a subscription' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/customers/NOSUBSCRIPTION/current_usage?subscription_id=123')
          .to_return(body: JSON.generate(status: 422, error: 'no_active_subscription'), status: 422)
      end

      it 'raises an error' do
        expect { resource.current_usage('DOESNOTEXIST', '123') }.to raise_error
      end
    end
  end
end
