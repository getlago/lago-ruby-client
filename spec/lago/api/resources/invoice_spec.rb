# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Invoice do
  subject(:resource) { described_class.new(client) }
  let(:client) { Lago::Api::Client.new }
  let(:factory_invoice) { FactoryBot.build(:invoice) }
  let(:lago_id) { 'this_is_lago_internal_id' }
  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record'
    }.to_json
  end
  let(:response_body) do
    {
      'invoice' => factory_invoice.to_h
    }
  end

  describe '#create' do
    let(:factory_invoice) { FactoryBot.build(:invoice) }
    let(:params) do
      {
        external_customer_id: '_ID_',
        currency: 'EUR',
        fees: [
          {
            add_on_code: '123',
            description: 'desc',
          }
        ],
      }
    end

    let(:request_body) do
      {
        'invoice' => params,
      }
    end

    before { factory_invoice.invoice_type = 'one_off' }

    context 'when one-off invoice is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/invoices')
          .with(body: request_body)
          .to_return(body: response_body.to_json, status: 200)
      end

      it 'returns invoice' do
        invoice = resource.create(params)

        expect(invoice.lago_id).to eq(factory_invoice.lago_id)
        expect(invoice.payment_status).to eq(factory_invoice.payment_status)
        expect(invoice.invoice_type).to eq('one_off')
      end
    end

    context 'when invoice is NOT successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/invoices')
          .with(body: request_body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#update' do
    let(:params) do
      { payment_status: 'succeeded', metadata: factory_invoice.metadata  }
    end

    let(:request_body) do
      {
        'invoice' => {
          'payment_status' => factory_invoice.payment_status,
          'metadata' => factory_invoice.metadata,
        },
      }
    end

    context 'when invoice is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/invoices/#{lago_id}")
          .with(body: request_body)
          .to_return(body: response_body.to_json, status: 200)
      end

      it 'returns invoice' do
        invoice = resource.update(params, lago_id)

        expect(invoice.lago_id).to eq(factory_invoice.lago_id)
        expect(invoice.payment_status).to eq(factory_invoice.payment_status)
        expect(invoice.metadata.first.key).to eq(factory_invoice.metadata.first[:key])
        expect(invoice.metadata.first.value).to eq(factory_invoice.metadata.first[:value])
      end
    end

    context 'when invoice is NOT successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/invoices/#{lago_id}")
          .with(body: request_body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, lago_id) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get' do
    context 'when invoice is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/invoices/#{lago_id}")
          .to_return(body: response_body.to_json, status: 200)
      end

      it 'returns an invoice' do
        invoice = resource.get(lago_id)

        expect(invoice.lago_id).to eq(factory_invoice.lago_id)
        expect(invoice.payment_status).to eq(factory_invoice.payment_status)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/invoices/#{lago_id}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get(lago_id) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:response) do
      {
        'invoices' => [
          factory_invoice.to_h,
        ],
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
        stub_request(:get, 'https://api.getlago.com/api/v1/invoices')
          .to_return(body: response, status: 200)
      end

      it 'returns invoices on the first page' do
        response = resource.get_all

        expect(response['invoices'].first['lago_id']).to eq(factory_invoice.lago_id)
        expect(response['invoices'].first['payment_status']).to eq(factory_invoice.payment_status)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/invoices?per_page=2&page=1')
          .to_return(body: response, status: 200)
      end

      it 'returns invoices on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['invoices'].first['lago_id']).to eq(factory_invoice.lago_id)
        expect(response['invoices'].first['payment_status']).to eq(factory_invoice.payment_status)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/invoices')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#download' do
    let(:response_body) do
      {
        'invoice' => factory_invoice.to_h,
      }
    end

    before do
      stub_request(:post, 'https://api.getlago.com/api/v1/invoices/123456/download')
        .with(body: {})
        .to_return(body: response_body.to_json, status: 200)
    end

    it 'returns invoice' do
      invoice = resource.download('123456')

      expect(invoice.lago_id).to eq(factory_invoice.lago_id)
    end

    context 'when invoice has not been generated yet' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/invoices/123456/download')
          .with(body: {})
          .to_return(body: '', status: 200)
      end

      it 'returns true' do
        result = resource.download('123456')

        expect(result).to eq(true)
      end
    end
  end

  describe '#refresh' do
    let(:response_body) do
      { 'invoice' => factory_invoice.to_h }
    end

    before do
      stub_request(:put, "https://api.getlago.com/api/v1/invoices/#{lago_id}/refresh")
        .with(body: {}).to_return(body: response_body.to_json, status: 200)
    end

    it 'returns invoice' do
      invoice = resource.refresh(lago_id)

      expect(invoice.lago_id).to eq(factory_invoice.lago_id)
      expect(invoice.status).to eq(factory_invoice.status)
    end
  end

  describe '#finalize' do
    let(:response_body) do
      { 'invoice' => factory_invoice.to_h }
    end

    before do
      stub_request(:put, "https://api.getlago.com/api/v1/invoices/#{lago_id}/finalize")
        .with(body: {}).to_return(body: response_body.to_json, status: 200)
    end

    it 'returns invoice' do
      invoice = resource.finalize(lago_id)

      expect(invoice.lago_id).to eq(factory_invoice.lago_id)
      expect(invoice.status).to eq(factory_invoice.status)
    end
  end

  describe '#retry_payment' do
    let(:response_body) do
      {
        'invoice' => factory_invoice.to_h,
      }
    end

    before do
      stub_request(:post, 'https://api.getlago.com/api/v1/invoices/123456/retry_payment')
        .with(body: {})
        .to_return(body: response_body.to_json, status: 200)
    end

    it 'returns invoice' do
      invoice = resource.retry_payment('123456')

      expect(invoice.lago_id).to eq(factory_invoice.id)
    end
  end
end
