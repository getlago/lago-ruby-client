# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Invoice do
  subject(:resource) { described_class.new(client) }
  let(:client) { Lago::Api::Client.new }
  let(:factory_invoice) { FactoryBot.build(:invoice) }

  describe '#update' do
    let(:params) do
      {
        lago_id: 'this_is_lago_internal_id',
        status: 'succeeded'
      }
    end
    let(:request_body) do
      {
        'invoice' => {
          'status' => factory_invoice.status
        }
      }
    end
    let(:response_body) do
      {
        'invoice' => factory_invoice.to_h
      }
    end

    context 'when invoice status is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/invoices/#{params[:lago_id]}")
          .with(body: request_body)
          .to_return(body: response_body.to_json, status: 200)
      end

      it 'returns invoice' do
        invoice = resource.update(params)

        expect(invoice.lago_id).to eq(factory_invoice.lago_id)
        expect(invoice.status).to eq(factory_invoice.status)
      end
    end

    context 'when invoice is NOT successfully updated' do
      let(:response) do
        {
          'status' => 422,
          'error' => 'Unprocessable Entity',
          'message' => 'Validation error on the record'
        }.to_json
      end

      before do
        stub_request(:put, "https://api.getlago.com/api/v1/invoices/#{params[:lago_id]}")
          .with(body: request_body)
          .to_return(body: response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
