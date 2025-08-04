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

  [
    ['when using resource', -> { described_class.new(client) }],
    ['when using client', -> { client.payment_requests }],
  ].each do |resource_name, resource_block|
    context resource_name do
      subject(:resource, &resource_block)

      describe '#get' do
        context 'when payment request is successfully fetched' do
          before do
            stub_request(:get, "https://api.getlago.com/api/v1/payment_requests/#{payment_request_id}")
              .to_return(body: payment_request_response, status: 200)
          end

          it 'returns a payment request' do
            payment_request = resource.get(payment_request_id)

            expect(payment_request.lago_id).to eq(payment_request_id)
            expect(payment_request.amount_cents).to eq(19_955)
            expect(payment_request.customer.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
            expect(payment_request.invoices.first.lago_id).to eq('f8e194df-5d90-4382-b146-c881d2c67f28')
          end
        end

        context 'when payment request is not found' do
          before do
            stub_request(:get, "https://api.getlago.com/api/v1/payment_requests/#{payment_request_id}")
              .to_return(body: error_response, status: 422)
          end

          it 'raises an error' do
            expect { resource.get(payment_request_id) }.to raise_error Lago::Api::HttpError
          end
        end
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

            expect(payment_request.lago_id).to eq("89b6b61e-4dbc-4307-ac96-4abcfa9e3e2d")
            expect(payment_request.email).to eq("gavin@overdue.test")
            expect(payment_request.amount_cents).to eq(199_55)
            expect(payment_request.amount_currency).to eq("EUR")
            expect(payment_request.payment_status).to eq("pending")
            expect(payment_request.created_at).to eq("2024-06-30T10:59:51Z")

            expect(payment_request.customer[:lago_id]).to eq("1a901a90-1a90-1a90-1a90-1a901a901a90")
            expect(payment_request.customer[:external_id]).to eq("gavin_001")
            expect(payment_request.customer[:name]).to eq("Gavin Belson")
            expect(payment_request.customer[:currency]).to eq("EUR")

            expect(payment_request.invoices.size).to eq(2)
            expect(payment_request.invoices.first[:lago_id]).to eq("f8e194df-5d90-4382-b146-c881d2c67f28")
            expect(payment_request.invoices.last[:lago_id]).to eq("a20b1805-d54c-4e57-873d-721cc153035e")
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
  end
end
