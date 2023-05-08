# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::TaxRate do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:tax_rate) { FactoryBot.build(:tax_rate) }
  let(:response) do
    {
      'tax_rate' => {
        'lago_id' => 'this-is-lago-id',
        'name' => tax_rate.name,
        'code' => tax_rate.code,
        'value' => tax_rate.value,
        'description' => tax_rate.description,
        'customers_count' => tax_rate.customers_count,
        'created_at' => '2022-04-29T08:59:51Z',
      }
    }.to_json
  end
  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#create' do
    let(:params) { tax_rate.to_h }
    let(:body) do
      { 'tax_rate' => tax_rate.to_h }
    end

    context 'when tax rate is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/tax_rates')
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns an tax rate' do
        tax = resource.create(params)

        expect(tax.lago_id).to eq('this-is-lago-id')
        expect(tax.name).to eq(tax_rate.name)
      end
    end

    context 'when tax_rate failed to create' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/tax_rates')
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#update' do
    let(:params) { tax_rate.to_h }
    let(:body) do
      { 'tax_rate' => tax_rate.to_h }
    end

    context 'when tax rate is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/tax_rates/#{tax_rate.code}")
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns an tax rate' do
        tax = resource.update(params, tax_rate.code)

        expect(tax.lago_id).to eq('this-is-lago-id')
        expect(tax.name).to eq(tax_rate.name)
      end
    end

    context 'when tax_rate failed to update' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/tax_rates/#{tax_rate.code}")
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, tax_rate.code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get' do
    context 'when tax rate is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/tax_rates/#{tax_rate.code}")
          .to_return(body: response, status: 200)
      end

      it 'returns an tax rate' do
        tax = resource.get(tax_rate.code)

        expect(tax.lago_id).to eq('this-is-lago-id')
        expect(tax.name).to eq(tax_rate.name)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/tax_rates/#{tax_rate.code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get(tax_rate.code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#destroy' do
    context 'when tax rate is successfully destroyed' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/tax_rates/#{tax_rate.code}")
          .to_return(body: response, status: 200)
      end

      it 'returns an tax rate' do
        tax = resource.destroy(tax_rate.code)

        expect(tax.lago_id).to eq('this-is-lago-id')
        expect(tax.name).to eq(tax_rate.name)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/tax_rates/#{tax_rate.code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy(tax_rate.code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:response) do
      {
        'tax_rates' => [
          {
            'lago_id' => 'this-is-lago-id',
            'name' => tax_rate.name,
            'code' => tax_rate.code,
            'value' => tax_rate.value,
            'description' => tax_rate.description,
            'customers_count' => tax_rate.customers_count,
            'created_at' => '2022-04-29T08:59:51Z',
          }
        ],
        'meta': {
          'current_page' => 1,
          'next_page' => 2,
          'prev_page' => nil,
          'total_pages' => 7,
          'total_count' => 63,
        }
      }.to_json
    end

    context 'when there is no options' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/tax_rates')
          .to_return(body: response, status: 200)
      end

      it 'returns tax rates on the first page' do
        response = resource.get_all

        expect(response['tax_rates'].first['lago_id']).to eq('this-is-lago-id')
        expect(response['tax_rates'].first['name']).to eq(tax_rate.name)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/tax_rates?per_page=2&page=1')
          .to_return(body: response, status: 200)
      end

      it 'returns tax rates on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['tax_rates'].first['lago_id']).to eq('this-is-lago-id')
        expect(response['tax_rates'].first['name']).to eq(tax_rate.name)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/tax_rates')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
