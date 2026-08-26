# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Quote do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:quote_response) { load_fixture('quote') }
  let(:quote_id) { JSON.parse(quote_response)['quote']['lago_id'] }

  describe '#get' do
    let(:endpoint) { "https://api.getlago.com/api/v1/quotes/#{quote_id}" }
    let(:not_found_response) do
      {
        'status' => 404,
        'error' => 'Not Found',
        'code' => 'quote_not_found',
      }
    end

    context 'when quote is successfully fetched' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: quote_response, status: 200)
      end

      it 'returns a quote' do
        quote = resource.get(quote_id)

        expect(quote.lago_id).to eq(quote_id)
        expect(quote.number).to eq('QT-2026-0001')
        expect(quote.order_type).to eq('subscription_creation')
        expect(quote.current_version.version).to eq(1)
        expect(quote.current_version.status).to eq('draft')
        expect(quote.owners.first.email).to eq('sales@getlago.com')
      end
    end

    context 'when is not found' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: not_found_response.to_json, status: 404)
      end

      it 'raises an error' do
        expect { resource.get(quote_id) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:endpoint) { "https://api.getlago.com/api/v1/quotes#{options}" }
    let(:options) { '' }
    let(:quotes_response) { load_fixture('quotes_index') }

    context 'when there is no options' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: quotes_response, status: 200)
      end

      it 'returns quotes on the first page' do
        response = resource.get_all

        expect(response['quotes'].first['lago_id']).to eq(quote_id)
        expect(response['quotes'].first['number']).to eq('QT-2026-0001')
        expect(response['quotes'].last['order_type']).to eq('one_off')
        expect(response['quotes'].last['current_version']).to be_nil
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      let(:options_hash) { { per_page: 2, page: 1, 'status[]' => 'draft', 'order_type[]' => 'one_off' } }
      let(:options) { "?#{URI.encode_www_form(options_hash)}" }

      before do
        stub_request(:get, endpoint)
          .to_return(body: quotes_response, status: 200)
      end

      it 'returns quotes on the selected page' do
        response = resource.get_all(options_hash)

        expect(response['quotes'].first['lago_id']).to eq(quote_id)
        expect(response['meta']['current_page']).to eq(1)
      end
    end
  end

  describe '#versions' do
    let(:endpoint) { "https://api.getlago.com/api/v1/quotes/#{quote_id}/versions#{options}" }
    let(:options) { '' }
    let(:quote_versions_response) { load_fixture('quote_versions_index') }

    context 'when there is no options' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: quote_versions_response, status: 200)
      end

      it 'returns the versions of the quote' do
        response = resource.versions(quote_id)

        expect(response.quote_versions.first.version).to eq(2)
        expect(response.quote_versions.first.status).to eq('draft')
        expect(response.quote_versions.last.status).to eq('voided')
        expect(response.quote_versions.last.void_reason).to eq('superseded')
        expect(response.meta.current_page).to eq(1)
      end
    end

    context 'when options are present' do
      let(:options_hash) { { per_page: 2, page: 1 } }
      let(:options) { "?#{URI.encode_www_form(options_hash)}" }

      before do
        stub_request(:get, endpoint)
          .to_return(body: quote_versions_response, status: 200)
      end

      it 'returns the versions on the selected page' do
        response = resource.versions(quote_id, options_hash)

        expect(response.quote_versions.first.version).to eq(2)
        expect(response.meta.current_page).to eq(1)
      end
    end
  end
end
