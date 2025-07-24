# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Payment do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:payment_response) { load_fixture('payment') }
  let(:payment_id) { JSON.parse(payment_response)['payment']['lago_id'] }

  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  [
    ['when using resource', -> { described_class.new(client) }],
    ['when using client', -> { client.payments }],
  ].each do |resource_name, resource_block|
    context resource_name do
      subject(:resource, &resource_block)

      describe '#get' do
        context 'when payment is successfully fetched' do
          before do
            stub_request(:get, "https://api.getlago.com/api/v1/payments/#{payment_id}")
              .to_return(body: payment_response, status: 200)
          end

          it 'returns a payment' do
            payment = resource.get(payment_id)

            # debugger

            expect(payment.lago_id).to eq(payment_id)
            expect(payment.amount_cents).to eq(100)
            expect(payment.invoice_ids).to eq(['ed267c66-8170-4d23-83e8-6d6e4fc735ef'])
            expect(payment.payment_status).to eq('succeeded')
            expect(payment.type).to eq('manual')
            expect(payment.reference).to eq('the reference')
          end
        end

        context 'when there is an issue' do
          before do
            stub_request(:get, "https://api.getlago.com/api/v1/payments/#{payment_id}")
              .to_return(body: error_response, status: 422)
          end

          it 'raises an error' do
            expect { resource.get(payment_id) }.to raise_error Lago::Api::HttpError
          end
        end
      end

      describe '#get_all' do
        let(:payments_response) do
          {
            'payments' => [JSON.parse(payment_response)['payment']],
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
            stub_request(:get, 'https://api.getlago.com/api/v1/payments')
              .to_return(body: payments_response, status: 200)
          end

          it 'returns payment requests on the first page' do
            response = resource.get_all

            expect(response['payments'].first['lago_id']).to eq(payment_id)
            expect(response['meta']['current_page']).to eq(1)
          end
        end

        context 'when options are present' do
          before do
            stub_request(:get, 'https://api.getlago.com/api/v1/payments?per_page=2&page=1')
              .to_return(body: payments_response, status: 200)
          end

          it 'returns payment requests on selected page' do
            response = resource.get_all({ per_page: 2, page: 1 })

            expect(response['payments'].first['lago_id']).to eq(payment_id)
            expect(response['meta']['current_page']).to eq(1)
          end
        end

        context 'when there is an issue' do
          before do
            stub_request(:get, 'https://api.getlago.com/api/v1/payments')
              .to_return(body: error_response, status: 422)
          end

          it 'raises an error' do
            expect { resource.get_all }.to raise_error(Lago::Api::HttpError)
          end
        end
      end

      describe '#create' do
        let(:params) { create(:create_payment).to_h }

        context 'when payment is successfully created' do
          before do
            stub_request(:post, 'https://api.getlago.com/api/v1/payments')
              .with(body: { payment: params })
              .to_return(body: payment_response, status: 200)
          end

          it 'returns a payment request', :aggregate_failures do
            payment = resource.create(params)

            expect(payment.lago_id).to eq(payment_id)
            expect(payment.amount_cents).to eq(100)
            expect(payment.type).to eq('manual')
            expect(payment.reference).to eq('the reference')
            expect(payment.payment_status).to eq('succeeded')
            expect(payment.created_at).to eq('2025-02-18T18:31:13Z')
          end
        end

        context 'when payment is not successfully created' do
          let(:response) do
            {
              'status' => 422,
              'error' => 'Unprocessable Entity',
              'message' => 'Validation error on the record',
            }.to_json
          end

          before do
            stub_request(:post, 'https://api.getlago.com/api/v1/payments')
              .with(body: { payment: params })
              .to_return(body: response, status: 422)
          end

          it 'raises an error' do
            expect { resource.create(params) }.to raise_error(Lago::Api::HttpError)
          end
        end
      end
    end
  end
end
