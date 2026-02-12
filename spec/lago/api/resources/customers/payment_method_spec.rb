# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Customers::PaymentMethod do
  subject(:resource) { described_class.new(client, resource_id) }

  let(:client) { Lago::Api::Client.new }
  let(:base_url) { 'https://api.getlago.com/api/v1/customers' }
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
        stub_request(:get, %r{#{base_url}/.*/payment_methods})
          .to_return(body: payment_methods_response, status: 200)
      end

      it 'returns payment methods on the first page', :aggregate_failures do
        response = resource.get_all

        expect(
          a_request(:get, %r{#{base_url}/#{resource_id}/payment_methods}),
        ).to have_been_made.once

        expect(response['payment_methods'].first).to have_attributes(
          lago_id: payment_method_id,
          is_default: factory_payment_method.is_default,
          payment_provider_code: factory_payment_method.payment_provider_code,
          payment_provider_name: factory_payment_method.payment_provider_name,
          payment_provider_type: factory_payment_method.payment_provider_type,
          provider_method_id: factory_payment_method.provider_method_id,
          created_at: factory_payment_method.created_at,
        )
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, %r{#{base_url}/.*/payment_methods?.*})
          .to_return(body: payment_methods_response, status: 200)
      end

      it 'returns payment methods on selected page', :aggregate_failures do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(
          a_request(:get, %r{#{base_url}/#{resource_id}/payment_methods\?page=1&per_page=2}),
        ).to have_been_made.once

        expect(response['payment_methods'].first['lago_id']).to eq(payment_method_id)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when the customer external id is invalid' do
      let(:error_response) do
        {
          'status' => 404,
          'error' => 'Not Found',
          'code' => 'customer_not_found',
        }.to_json
      end

      before do
        stub_request(:get, "#{base_url}/#{resource_id}/payment_methods")
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
        stub_request(:delete, %r{#{base_url}/.*/payment_methods/.*})
          .to_return(body: payment_method_response, status: 200)
      end

      it 'returns the payment method' do
        payment_method = resource.destroy(payment_method_id)

        expect(
          a_request(:delete, %r{#{base_url}/#{resource_id}/payment_methods/#{payment_method_id}}),
        ).to have_been_made.once

        expect(payment_method).to have_attributes(
          lago_id: payment_method_id,
          is_default: factory_payment_method.is_default,
          payment_provider_code: factory_payment_method.payment_provider_code,
          payment_provider_name: factory_payment_method.payment_provider_name,
          payment_provider_type: factory_payment_method.payment_provider_type,
          provider_method_id: factory_payment_method.provider_method_id,
          created_at: factory_payment_method.created_at,
        )
      end
    end

    context 'when the payment method id is invalid' do
      let(:error_response) do
        {
          'status' => 404,
          'error' => 'Not Found',
          'code' => 'payment_method_not_found',
        }.to_json
      end

      before do
        stub_request(:delete, "#{base_url}/#{resource_id}/payment_methods/#{payment_method_id}")
          .to_return(body: error_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.destroy(payment_method_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#set_as_default' do
    context 'when payment method is successfully set as default' do
      let(:payment_method_response_with_default) do
        response = JSON.parse(payment_method_response)
        response['payment_method']['is_default'] = true
        response.to_json
      end

      before do
        stub_request(:put, %r{#{base_url}/.*/payment_methods/.*/set_as_default})
          .with(body: {})
          .to_return(body: payment_method_response_with_default, status: 200)
      end

      it 'returns the payment method with is_default true' do
        payment_method = resource.set_as_default(payment_method_id)

        expect(
          a_request(:put, %r{#{base_url}/#{resource_id}/payment_methods/#{payment_method_id}/set_as_default}),
        ).to have_been_made.once

        expect(payment_method).to have_attributes(
          lago_id: payment_method_id,
          is_default: true,
          payment_provider_code: factory_payment_method.payment_provider_code,
          payment_provider_name: factory_payment_method.payment_provider_name,
          payment_provider_type: factory_payment_method.payment_provider_type,
          provider_method_id: factory_payment_method.provider_method_id,
          created_at: factory_payment_method.created_at,
        )
      end
    end

    context 'when the payment method id is invalid' do
      let(:error_response) do
        {
          'status' => 404,
          'error' => 'Not Found',
          'code' => 'payment_method_not_found',
        }.to_json
      end

      before do
        stub_request(:put, "#{base_url}/#{resource_id}/payment_methods/#{payment_method_id}/set_as_default")
          .with(body: {})
          .to_return(body: error_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.set_as_default(payment_method_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end
end
