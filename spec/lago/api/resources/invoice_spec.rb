# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Invoice do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:invoice_response) { load_fixture('invoice') }
  let(:invoice_id) { JSON.parse(invoice_response)['invoice']['lago_id'] }
  let(:tax) { create(:create_tax) }

  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#create' do
    let(:params) do
      {
        external_customer_id: '_ID_',
        currency: 'EUR',
        net_payment_term: 0,
        fees: [
          {
            add_on_code: '123',
            description: 'desc',
            tax_codes: [tax.code],
          }
        ],
      }
    end

    context 'when one-off invoice is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/invoices')
          .with(body: { invoice: params })
          .to_return(body: invoice_response, status: 200)
      end

      it 'returns invoice' do
        invoice = resource.create(params)

        expect(invoice).to have_attributes(
          lago_id: invoice_id,
          net_payment_term: 0,
          payment_due_date: '2022-06-02',
          payment_status: 'succeeded',
          payment_overdue: false,
          invoice_type: 'one_off'
        )
        expect(invoice.applied_taxes.first.tax_code).to eq('tax_code')
      end
    end

    context 'when invoice is NOT successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/invoices')
          .with(body: { invoice: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#update' do
    let(:params) { create(:update_invoice).to_h }

    context 'when invoice is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/invoices/#{invoice_id}")
          .with(body: { invoice: params })
          .to_return(body: invoice_response, status: 200)
      end

      it 'returns invoice' do
        invoice = resource.update(params, invoice_id)

        expect(invoice.lago_id).to eq(invoice_id)
        expect(invoice.payment_status).to eq('succeeded')
        expect(invoice.net_payment_term).to eq(0)
        expect(invoice.payment_due_date).to eq('2022-06-02')
        expect(invoice.metadata.first.key).to eq('key')
        expect(invoice.metadata.first.value).to eq('value')
      end
    end

    context 'when invoice is NOT successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/invoices/#{invoice_id}")
          .with(body: { invoice: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, invoice_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#get' do
    context 'when invoice is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/invoices/#{invoice_id}")
          .to_return(body: invoice_response, status: 200)
      end

      it 'returns an invoice' do
        invoice = resource.get(invoice_id)

        expect(invoice.lago_id).to eq(invoice_id)
        expect(invoice.net_payment_term).to eq(0)
        expect(invoice.payment_status).to eq('succeeded')
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/invoices/#{invoice_id}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get(invoice_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#get_all' do
    let(:invoices_response) do
      {
        'invoices' => [JSON.parse(invoice_response)['invoice']],
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
          .to_return(body: invoices_response, status: 200)
      end

      it 'returns invoices on the first page' do
        response = resource.get_all

        expect(response['invoices'].first['lago_id']).to eq(invoice_id)
        expect(response['invoices'].first['payment_status']).to eq('succeeded')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/invoices?per_page=2&page=1')
          .to_return(body: invoices_response, status: 200)
      end

      it 'returns invoices on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['invoices'].first['lago_id']).to eq(invoice_id)
        expect(response['invoices'].first['payment_status']).to eq('succeeded')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/invoices')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#download' do
    before do
      stub_request(:post, "https://api.getlago.com/api/v1/invoices/#{invoice_id}/download")
        .with(body: {})
        .to_return(body: invoice_response, status: 200)
    end

    it 'returns invoice' do
      invoice = resource.download(invoice_id)

      expect(invoice.lago_id).to eq(invoice_id)
    end

    context 'when invoice has not been generated yet' do
      before do
        stub_request(:post, "https://api.getlago.com/api/v1/invoices/#{invoice_id}/download")
          .with(body: {})
          .to_return(body: '', status: 200)
      end

      it 'returns true' do
        result = resource.download(invoice_id)

        expect(result).to eq(true)
      end
    end
  end

  describe '#refresh' do
    before do
      stub_request(:put, "https://api.getlago.com/api/v1/invoices/#{invoice_id}/refresh")
        .with(body: {}).to_return(body: invoice_response, status: 200)
    end

    it 'returns invoice' do
      invoice = resource.refresh(invoice_id)

      expect(invoice.lago_id).to eq(invoice_id)
      expect(invoice.status).to eq('finalized')
    end
  end

  describe '#finalize' do
    let(:response_body) do
      { 'invoice' => factory_invoice.to_h }
    end

    before do
      stub_request(:put, "https://api.getlago.com/api/v1/invoices/#{invoice_id}/finalize")
        .with(body: {}).to_return(body: invoice_response, status: 200)
    end

    it 'returns invoice' do
      invoice = resource.finalize(invoice_id)

      expect(invoice.lago_id).to eq(invoice_id)
      expect(invoice.status).to eq('finalized')
    end
  end

  describe '#lose_dispute' do
    let(:response_body) do
      { 'invoice' => factory_invoice.to_h }
    end

    before do
      stub_request(:put, "https://api.getlago.com/api/v1/invoices/#{invoice_id}/lose_dispute")
        .with(body: {}).to_return(body: invoice_response, status: 200)
    end

    it 'returns invoice' do
      invoice = resource.lose_dispute(invoice_id)

      expect(invoice.lago_id).to eq(invoice_id)
      expect(invoice.payment_dispute_lost_at).to eq('2022-04-29T08:59:51Z')
    end
  end

  describe '#retry_payment' do
    before do
      stub_request(:post, "https://api.getlago.com/api/v1/invoices/#{invoice_id}/retry_payment")
        .with(body: {})
        .to_return(body: '', status: 200)
    end

    it 'returns invoice' do
      result = resource.retry_payment(invoice_id)

      expect(result).to eq(true)
    end
  end

  describe '#payment_url' do
    let(:url_response) do
      {
        'invoice_payment_details' => {
          'payment_url' => 'https://example.com',
        }
      }.to_json
    end

    before do
      stub_request(:post, "https://api.getlago.com/api/v1/invoices/#{invoice_id}/payment_url")
        .with(body: {})
        .to_return(body: url_response, status: 200)
    end

    it 'returns payment url' do
      result = resource.payment_url(invoice_id)

      expect(result.payment_url).to eq('https://example.com')
    end
  end
end
