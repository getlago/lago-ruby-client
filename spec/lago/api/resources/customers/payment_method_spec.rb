# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Customers::PaymentMethod do
  subject(:resource) { described_class.new(client, resource_id) }

  let(:client) { Lago::Api::Client.new }

  let(:resource_id) { 'customer_external_id' }
  let(:factory_payment_method) { build(:payment_method) }
  let(:payment_method_response) do
    {
      'payment_method' => {
        'lago_id' => factory_payment_method.lago_id,
        'is_default' => factory_payment_method.is_default,
        'payment_provider_code' => factory_payment_method.payment_provider_code,
        'payment_provider_name' => factory_payment_method.payment_provider_name,
        'payment_provider_type' => factory_payment_method.payment_provider_type,
        'provider_method_id' => factory_payment_method.provider_method_id,
        'created_at' => factory_payment_method.created_at,
      },
    }.to_json
  end
  let(:payment_method_id) { factory_payment_method.lago_id }

  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#get_all' do
    let(:payment_methods_response) do
      {
        'payment_methods' => [JSON.parse(payment_method_response)['payment_method']],
        'meta': {
          'current_page' => 1,
          'next_page' => 2,
          'prev_page' => nil,
          'total_pages' => 7,
          'total_count' => 63,
        },
      }.to_json
    end

    context 'when there is no options' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{resource_id}/payment_methods")
          .to_return(body: payment_methods_response, status: 200)
      end

      it 'returns payment methods on the first page' do
        response = resource.get_all

        expect(response['payment_methods'].first['lago_id']).to eq(payment_method_id)
        expect(response['payment_methods'].first['provider_method_id']).to eq('pm_123456')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{resource_id}/payment_methods?per_page=2&page=1")
          .to_return(body: payment_methods_response, status: 200)
      end

      it 'returns payment methods on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['payment_methods'].first['lago_id']).to eq(payment_method_id)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{resource_id}/payment_methods")
          .to_return(body: error_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#destroy' do
    context 'when payment method is successfully destroyed' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/customers/#{resource_id}/payment_methods/#{payment_method_id}")
          .to_return(body: payment_method_response, status: 200)
      end

      it 'returns the payment method' do
        payment_method = resource.destroy(payment_method_id)

        expect(payment_method.lago_id).to eq(payment_method_id)
        expect(payment_method.provider_method_id).to eq('pm_123456')
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/customers/#{resource_id}/payment_methods/#{payment_method_id}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy(payment_method_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#set_as_default' do
    context 'when payment method is successfully set as default' do
      let(:default_response) do
        pm = JSON.parse(payment_method_response)
        pm['payment_method']['is_default'] = true
        pm.to_json
      end

      before do
        stub_request(:put, "https://api.getlago.com/api/v1/customers/#{resource_id}/payment_methods/#{payment_method_id}/set_as_default")
          .with(body: {})
          .to_return(body: default_response, status: 200)
      end

      it 'returns the payment method with is_default true' do
        payment_method = resource.set_as_default(payment_method_id)

        expect(payment_method.lago_id).to eq(payment_method_id)
        expect(payment_method.is_default).to be(true)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/customers/#{resource_id}/payment_methods/#{payment_method_id}/set_as_default")
          .with(body: {})
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.set_as_default(payment_method_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end
end
