# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::PaymentRequest do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:payment_request_response) { load_fixture('payment_request') }
  let(:payment_request_id) { JSON.parse(payment_request_response)['payment_request']['lago_id'] }

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
        stub_request(:get, 'https://api.getlago.com/api/v1/payment_requests')
          .to_return(body: payment_requests_response, status: 200)
      end

      it 'returns payment requests on the first page' do
        response = resource.get_all

        expect(response['payment_requests'].first['lago_id']).to eq(payment_request_id)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/payment_requests?per_page=2&page=1')
          .to_return(body: payment_requests_response, status: 200)
      end

      it 'returns payment requests on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['payment_requests'].first['lago_id']).to eq(payment_request_id)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/payment_requests')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe "#create" do
    let(:params) { create(:create_payment_request).to_h }

    context "when payment request is successfully created" do
      before do
        stub_request(:post, "https://api.getlago.com/api/v1/payment_requests")
          .with(body: { payment_request: params })
          .to_return(body: payment_request_response, status: 200)
      end

      it "returns a payment request", :aggregate_failures do
        payment_request = resource.create(params)

        expect(payment_request.customer[:external_id]).to eq("1a901a90-1a90-1a90-1a90-1a901a901a90")
        expect(payment_request.customer[:name]).to eq("Gavin Belson")
        expect(payment_request.customer[:currency]).to eq("EUR")
        expect(payment_request.customer[:net_payment_term]).to eq(nil)
        expect(payment_request.customer[:tax_identification_number]).to eq("EU123456789")
        expect(payment_request.customer[:billing_configuration].invoice_grace_period).to eq(3)
        expect(payment_request.customer[:billing_configuration].provider_customer_id).to eq("cus_12345")
        expect(payment_request.customer[:billing_configuration].provider_payment_methods).to eq(["card"])
        expect(payment_request.customer[:shipping_address].city).to eq("Woodland Hills")
        expect(payment_request.customer[:shipping_address].country).to eq("US")
        expect(payment_request.customer[:integration_customers].first.external_customer_id).to eq("123456789")
        expect(payment_request.customer[:integration_customers].first.type).to eq("netsuite")
        expect(payment_request.customer[:metadata].first.key).to eq("key")
        expect(payment_request.customer[:metadata].first.value).to eq("value")
        expect(payment_request.customer[:taxes].map(&:code)).to eq(["tax_code"])
      end
    end

    context "when payment request is not successfully created" do
      let(:response) do
        {
          "status" => 422,
          "error" => "Unprocessable Entity",
          "message" => "Validation error on the record",
        }.to_json
      end

      before do
        stub_request(:post, "https://api.getlago.com/api/v1/payment_requests")
          .with(body: { payment_request: params })
          .to_return(body: response, status: 422)
      end

      it "raises an error" do
        expect { resource.create(params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end
end
