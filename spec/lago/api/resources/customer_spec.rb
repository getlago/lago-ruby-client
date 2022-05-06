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
        stub_request(:post, 'http://api.lago.dev/api/v1/customers')
          .with(body: body)
          .to_return(body: body.to_json, status: 200)
      end

      it 'returns customer' do
        customer = resource.create(params)

        expect(customer.customer_id).to eq(factory_customer.customer_id)
        expect(customer.name).to eq(factory_customer.name)
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
        stub_request(:post, 'http://api.lago.dev/api/v1/customers')
          .with(body: body)
          .to_return(body: response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
