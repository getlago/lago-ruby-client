# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::InvoiceCollection do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#get_all' do
    let(:invoice_collections_response) { load_fixture('invoice_collection_index') }

    context 'when there is no options' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/analytics/invoice_collection')
          .to_return(body: invoice_collections_response, status: 200)
      end

      it 'returns gross revenue' do
        response = resource.get_all

        expect(response['invoice_collections'].first['currency']).to eq('EUR')
        expect(response['invoice_collections'].first['amount_cents']).to eq(100)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/analytics/invoice_collection?currency=EUR')
          .to_return(body: invoice_collections_response, status: 200)
      end

      it 'returns invoice collection' do
        response = resource.get_all({ currency: 'EUR' })

        expect(response['invoice_collections'].first['currency']).to eq('EUR')
        expect(response['invoice_collections'].first['amount_cents']).to eq(100)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/analytics/invoice_collection')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
