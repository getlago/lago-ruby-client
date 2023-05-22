# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Tax do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:tax) { FactoryBot.build(:tax) }
  let(:response) do
    {
      'tax' => {
        'lago_id' => 'this-is-lago-id',
        'name' => tax.name,
        'code' => tax.code,
        'rate' => tax.rate,
        'description' => tax.description,
        'customers_count' => tax.customers_count,
        'applied_to_organization' => tax.applied_to_organization,
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
    let(:params) { tax.to_h }
    let(:body) do
      { 'tax' => tax.to_h }
    end

    context 'when tax is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/taxes')
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns an tax' do
        tax = resource.create(params)

        expect(tax.lago_id).to eq('this-is-lago-id')
        expect(tax.name).to eq(tax.name)
      end
    end

    context 'when tax failed to create' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/taxes')
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#update' do
    let(:params) { tax.to_h }
    let(:body) do
      { 'tax' => tax.to_h }
    end

    context 'when tax is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/taxes/#{tax.code}")
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns a tax' do
        response = resource.update(params, tax.code)

        expect(response.lago_id).to eq('this-is-lago-id')
        expect(response.name).to eq(tax.name)
      end
    end

    context 'when tax failed to update' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/taxes/#{tax.code}")
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, tax.code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get' do
    context 'when tax is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/taxes/#{tax.code}")
          .to_return(body: response, status: 200)
      end

      it 'returns a tax' do
        response = resource.get(tax.code)

        expect(response.lago_id).to eq('this-is-lago-id')
        expect(response.name).to eq(tax.name)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/taxes/#{tax.code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get(tax.code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#destroy' do
    context 'when tax is successfully destroyed' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/taxes/#{tax.code}")
          .to_return(body: response, status: 200)
      end

      it 'returns a tax' do
        response = resource.destroy(tax.code)

        expect(response.lago_id).to eq('this-is-lago-id')
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/taxes/#{tax.code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy(tax.code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:response) do
      {
        'taxes' => [
          {
            'lago_id' => 'this-is-lago-id',
            'name' => tax.name,
            'code' => tax.code,
            'rate' => tax.rate,
            'description' => tax.description,
            'customers_count' => tax.customers_count,
            'applied_to_organization' => tax.applied_to_organization,
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
        stub_request(:get, 'https://api.getlago.com/api/v1/taxes')
          .to_return(body: response, status: 200)
      end

      it 'returns tax on the first page' do
        response = resource.get_all

        expect(response['taxes'].first['lago_id']).to eq('this-is-lago-id')
        expect(response['taxes'].first['name']).to eq(tax.name)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/taxes?per_page=2&page=1')
          .to_return(body: response, status: 200)
      end

      it 'returns tax on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['taxes'].first['lago_id']).to eq('this-is-lago-id')
        expect(response['taxes'].first['name']).to eq(tax.name)
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
