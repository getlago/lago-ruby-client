# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::PaymentReceipt do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:payment_receipt_response) { load_fixture('payment_receipt') }
  let(:payment_receipt_id) { JSON.parse(payment_receipt_response)['payment_receipt']['lago_id'] }

  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  [
    ['when using resource', -> { described_class.new(client) }],
    ['when using client', -> { client.payment_receipts }],
  ].each do |resource_name, resource_block|
    context resource_name do
      subject(:resource, &resource_block)

      describe '#get_all' do
        let(:payment_receipts_response) do
          {
            'payment_receipts' => [JSON.parse(payment_receipt_response)['payment_receipt']],
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
            stub_request(:get, 'https://api.getlago.com/api/v1/payment_receipts')
              .to_return(body: payment_receipts_response, status: 200)
          end

          it 'returns payment receipts on the first page' do
            response = resource.get_all

            expect(response['payment_receipts'].first['lago_id']).to eq(payment_receipt_id)
            expect(response['meta']['current_page']).to eq(1)
          end
        end

        context 'when options are present' do
          before do
            stub_request(:get, 'https://api.getlago.com/api/v1/payment_receipts?per_page=2&page=1')
              .to_return(body: payment_receipts_response, status: 200)
          end

          it 'returns payment receipts on selected page' do
            response = resource.get_all({ per_page: 2, page: 1 })

            expect(response['payment_receipts'].first['lago_id']).to eq(payment_receipt_id)
            expect(response['meta']['current_page']).to eq(1)
          end
        end

        context 'when there is an issue' do
          before do
            stub_request(:get, 'https://api.getlago.com/api/v1/payment_receipts')
              .to_return(body: error_response, status: 422)
          end

          it 'raises an error' do
            expect { resource.get_all }.to raise_error(Lago::Api::HttpError)
          end
        end
      end

      describe '#get' do
        context 'when the request is successful' do
          before do
            stub_request(:get, "https://api.getlago.com/api/v1/payment_receipts/#{payment_receipt_id}")
              .to_return(body: payment_receipt_response, status: 200)
          end

          it 'returns the payment receipt' do
            response = resource.get(payment_receipt_id)

            expect(response['lago_id']).to eq(payment_receipt_id)
          end
        end

        context 'when there is an issue' do
          before do
            stub_request(:get, "https://api.getlago.com/api/v1/payment_receipts/#{payment_receipt_id}")
              .to_return(body: error_response, status: 422)
          end

          it 'raises an error' do
            expect { resource.get(payment_receipt_id) }.to raise_error(Lago::Api::HttpError)
          end
        end
      end
    end
  end
end
