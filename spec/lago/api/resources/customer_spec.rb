# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Customer do
  let(:client) { Lago::Api::Client.new }
  let(:factory_customer) { FactoryBot.build(:customer) }
  subject(:resource) { described_class.new(client) }

  describe '#create' do
    let(:params) { { 'customer' => factory_customer.to_h } }

    context 'when customer is successfully created or finded' do
      let(:response) do
        {
          'customer' => factory_customer.to_h
        }.to_json
      end

      before do
        stub_request(:post, 'http://api.lago.dev/api/v1/customers')
          .to_return(body: response, status: 200)
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
          .to_return(body: response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
