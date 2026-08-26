# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::OrderForm do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:order_form_response) { load_fixture('order_form') }
  let(:order_form_id) { JSON.parse(order_form_response)['order_form']['lago_id'] }
  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#get' do
    let(:endpoint) { "https://api.getlago.com/api/v1/order_forms/#{order_form_id}" }

    context 'when order form is successfully fetched' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: order_form_response, status: 200)
      end

      it 'returns an order form' do
        order_form = resource.get(order_form_id)

        expect(order_form.lago_id).to eq(order_form_id)
        expect(order_form.number).to eq('OF-2026-0001')
        expect(order_form.status).to eq('generated')
        expect(order_form.void_reason).to be_nil
        expect(order_form.signed_document_url).to be_nil
        expect(order_form.lago_quote_version_id).to eq('4d234d23-4d23-4d23-4d23-4d234d234d23')
      end
    end

    context 'when is not found' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: { 'status' => 404, 'error' => 'Not Found' }.to_json, status: 404)
      end

      it 'raises an error' do
        expect { resource.get(order_form_id) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:endpoint) { "https://api.getlago.com/api/v1/order_forms#{options}" }
    let(:options) { '' }
    let(:order_forms_response) { load_fixture('order_forms_index') }

    context 'when there is no options' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: order_forms_response, status: 200)
      end

      it 'returns order forms on the first page' do
        response = resource.get_all

        expect(response['order_forms'].first['number']).to eq('OF-2026-0001')
        expect(response['order_forms'].last['status']).to eq('voided')
        expect(response['order_forms'].last['void_reason']).to eq('manual')
        expect(response['order_forms'].last['expires_at']).to be_nil
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      let(:options_hash) { { per_page: 2, page: 1, 'status[]' => 'generated', search_term: 'OF-2026' } }
      let(:options) { "?#{URI.encode_www_form(options_hash)}" }

      before do
        stub_request(:get, endpoint)
          .to_return(body: order_forms_response, status: 200)
      end

      it 'returns order forms on the selected page' do
        response = resource.get_all(options_hash)

        expect(response['order_forms'].first['number']).to eq('OF-2026-0001')
        expect(response['meta']['current_page']).to eq(1)
      end
    end
  end

  describe '#mark_as_signed' do
    let(:endpoint) { "https://api.getlago.com/api/v1/order_forms/#{order_form_id}/mark_as_signed" }
    let(:signed_response) { load_fixture('signed_order_form') }

    context 'when no params are given' do
      before do
        stub_request(:post, endpoint)
          .with(body: {})
          .to_return(body: signed_response, status: 200)
      end

      it 'returns the signed order form' do
        order_form = resource.mark_as_signed(order_form_id)

        expect(order_form.lago_id).to eq(order_form_id)
        expect(order_form.status).to eq('signed')
      end
    end

    context 'when params are given' do
      let(:params) do
        {
          signed_document: 'data:application/pdf;base64,JVBERi0xLjQKJcfs',
          execution_mode: 'execute_in_lago',
          execute_at: '2026-07-01T00:00:00Z',
        }
      end

      before do
        stub_request(:post, endpoint)
          .with(body: { order_form: params })
          .to_return(body: signed_response, status: 200)
      end

      it 'returns the signed order form' do
        order_form = resource.mark_as_signed(order_form_id, params)

        expect(order_form.status).to eq('signed')
        expect(order_form.signed_at).to eq('2026-05-02T10:15:00Z')
        expect(order_form.signed_document_url).to include('OF-2026-0001')
      end
    end

    context 'when the order form cannot be signed' do
      before do
        stub_request(:post, endpoint)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.mark_as_signed(order_form_id) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#void' do
    let(:endpoint) { "https://api.getlago.com/api/v1/order_forms/#{order_form_id}/void" }

    context 'when the order form is successfully voided' do
      before do
        stub_request(:post, endpoint)
          .with(body: {})
          .to_return(body: order_form_response, status: 200)
      end

      it 'returns the order form' do
        order_form = resource.void(order_form_id)

        expect(order_form.lago_id).to eq(order_form_id)
      end
    end

    context 'when the order form cannot be voided' do
      before do
        stub_request(:post, endpoint)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.void(order_form_id) }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
