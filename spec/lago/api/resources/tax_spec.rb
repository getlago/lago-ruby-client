# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Tax do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:tax_response) { load_fixture('tax') }
  let(:tax_code) { JSON.parse(tax_response)['tax']['code'] }

  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#create' do
    let(:params) { create(:create_tax).to_h }

    context 'when tax is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/taxes')
          .with(body: { tax: params })
          .to_return(body: tax_response, status: 200)
      end

      it 'returns an tax' do
        tax = resource.create(params)

        expect(tax.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
        expect(tax.name).to eq('tax_name')
      end
    end

    context 'when tax failed to create' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/taxes')
          .with(body: { tax: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#update' do
    let(:params) { create(:create_tax).to_h }

    context 'when tax is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/taxes/#{tax_code}")
          .with(body: { tax: params })
          .to_return(body: tax_response, status: 200)
      end

      it 'returns a tax' do
        response = resource.update(params, tax_code)

        expect(response.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
        expect(response.name).to eq('tax_name')
      end
    end

    context 'when tax failed to update' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/taxes/#{tax_code}")
          .with(body: { tax: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, tax_code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get' do
    context 'when tax is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/taxes/#{tax_code}")
          .to_return(body: tax_response, status: 200)
      end

      it 'returns a tax' do
        response = resource.get(tax_code)

        expect(response.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
        expect(response.name).to eq('tax_name')
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/taxes/#{tax_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get(tax_code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#destroy' do
    context 'when tax is successfully destroyed' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/taxes/#{tax_code}")
          .to_return(body: tax_response, status: 200)
      end

      it 'returns a tax' do
        response = resource.destroy(tax_code)

        expect(response.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/taxes/#{tax_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy(tax_code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:taxes_response) { load_fixture(:taxes) }

    context 'when there is no options' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/taxes')
          .to_return(body: taxes_response, status: 200)
      end

      it 'returns tax on the first page' do
        response = resource.get_all

        expect(response['taxes'].first['lago_id']).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
        expect(response['taxes'].first['name']).to eq('tax_name')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/taxes?per_page=2&page=1')
          .to_return(body: taxes_response, status: 200)
      end

      it 'returns tax on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['taxes'].first['lago_id']).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
        expect(response['taxes'].first['name']).to eq('tax_name')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/taxes')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
