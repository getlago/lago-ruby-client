# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Customers::PaymentRequest do
  subject(:resource) { described_class.new(client, resource_id) }

  let(:client) { Lago::Api::Client.new }

  let(:resource_id) { 'customer_external_id' }
  let(:payment_request_response) { load_fixture('payment_request') }
  let(:payment_request_id) { JSON.parse(payment_request_response)['payment_request']['lago_id'] }
  let(:tax) { create(:create_tax) }

  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#get_all' do
    let(:payment_requests_response) do
      {
        'payment_requests' => [JSON.parse(payment_request_response)['payment_request']],
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
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{resource_id}/payment_requests")
          .to_return(body: payment_requests_response, status: 200)
      end

      it 'returns payment_requests on the first page' do
        response = resource.get_all

        expect(response['payment_requests'].first['lago_id']).to eq(payment_request_id)
        expect(response['payment_requests'].first['payment_status']).to eq('pending')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{resource_id}/payment_requests?per_page=2&page=1")
          .to_return(body: payment_requests_response, status: 200)
      end

      it 'returns payment_requests on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['payment_requests'].first['lago_id']).to eq(payment_request_id)
        expect(response['payment_requests'].first['payment_status']).to eq('pending')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{resource_id}/payment_requests")
          .to_return(body: error_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error(Lago::Api::HttpError)
      end
    end
  end
end
