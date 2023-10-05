# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Fee do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:fee_response) { load_fixture('fee') }
  let(:fee_json) { JSON.parse(fee_response)['fee'] }
  let(:fee_id) { fee_json['lago_id'] }
  let(:fee_invoice_display_name) { fee_json['invoice_display_name'] }

  let(:error_response) do
    {
      'status' => 404,
      'error' => 'Not Found',
      'code' => 'fee_not_found',
    }.to_json
  end

  describe '#get' do
    context 'when fee is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/fees/#{fee_id}")
          .to_return(body: fee_response, status: 200)
      end

      it 'returns a fee' do
        fee = resource.get(fee_id)

        expect(fee.lago_id).to eq(fee_id)
        expect(fee.invoice_display_name).to eq(fee_invoice_display_name)
      end
    end

    context 'when fee is not found' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/fees/#{fee_id}")
          .to_return(body: error_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.get(fee_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#get_all' do
    let(:fees_response) do
      {
        'fees' => [JSON.parse(fee_response)['fee']],
        'meta' => {
          'current_page' => 1,
          'next_page' => 2,
          'prev_page' => nil,
          'total_pages' => 7,
          'total_count' => 63,
        },
      }.to_json
    end

    context 'without filters' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/fees')
          .to_return(body: fees_response, status: 200)
      end

      it 'returns fees of the first page' do
        response = resource.get_all

        expect(response['fees'].first['lago_id']).to eq(fee_id)
        expect(response['fees'].first['invoice_display_name']).to eq(fee_invoice_display_name)
      end

      context 'when filters are present' do
        before do
          stub_request(:get, 'https://api.getlago.com/api/v1/fees?per_page=2&page=1')
            .to_return(body: fees_response, status: 200)
        end

        it 'returns fees on selected page' do
          response = resource.get_all(per_page: 2, page: 1)

          expect(response['fees'].first['lago_id']).to eq(fee_id)
          expect(response['meta']['current_page']).to eq(1)
        end
      end

      context 'when response is not a 200' do
        before do
          stub_request(:get, 'https://api.getlago.com/api/v1/fees')
            .to_return(body: error_response, status: 404)
        end

        it 'raises an error' do
          expect { resource.get_all }.to raise_error(Lago::Api::HttpError)
        end
      end
    end
  end

  describe '#update' do
    let(:params) { create(:update_fee).to_h }

    context 'when fee is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/fees/#{fee_id}")
          .with(body: { fee: params })
          .to_return(body: fee_response, status: 200)
      end

      it 'returns a fee' do
        fee = resource.update(params, fee_id)

        expect(fee.lago_id).to eq(fee_id)
      end
    end

    context 'when invoice is not successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/fees/#{fee_id}")
          .with(body: { fee: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, fee_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end
end
