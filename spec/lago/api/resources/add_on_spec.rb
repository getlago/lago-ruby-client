# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::AddOn do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:factory_add_on) { build(:add_on) }
  let(:response) do
    {
      'add_on' => {
        'lago_id' => 'this-is-lago-id',
        'name' => factory_add_on.name,
        'code' => factory_add_on.code,
        'amount_cents' => factory_add_on.amount_cents,
        'amount_currency' => factory_add_on.amount_currency,
        'description' => factory_add_on.description,
        'created_at' => '2022-04-29T08:59:51Z',
        'taxes' => [
          {
            'lago_id' => '1a901a90-1a90-1a90-1a90-1a901a901a90',
            'name' => 'tax_name',
            'code' => 'tax_code',
            'rate' => 15.0,
            'description' => 'tax_desc',
            'add_ons_count' => 0,
            'customers_count' => 0,
            'plans_count' => 0,
            'charges_count' => 0,
            'applied_to_organization' => false,
            'created_at' => '2022-04-29T08:59:51Z'
          }
        ]
      }
    }.to_json
  end
  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record'
    }.to_json
  end

  describe '#create' do
    let(:params) { factory_add_on.to_h }
    let(:body) do
      {
        'add_on' => factory_add_on.to_h
      }
    end

    context 'when add-on is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/add_ons')
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns an add-on' do
        add_on = resource.create(params)

        expect(add_on.lago_id).to eq('this-is-lago-id')
        expect(add_on.name).to eq(factory_add_on.name)
        expect(add_on.taxes.map(&:code)).to eq(['tax_code'])
      end
    end

    context 'when add_on failed to create' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/add_ons')
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#update' do
    let(:params) { factory_add_on.to_h }
    let(:body) do
      {
        'add_on' => factory_add_on.to_h
      }
    end

    context 'when add-on is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/add_ons/#{factory_add_on.code}")
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns an add-on' do
        add_on = resource.update(params, factory_add_on.code)

        expect(add_on.lago_id).to eq('this-is-lago-id')
        expect(add_on.name).to eq(factory_add_on.name)
      end
    end

    context 'when add_on failed to update' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/add_ons/#{factory_add_on.code}")
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, factory_add_on.code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get' do
    context 'when add-on is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/add_ons/#{factory_add_on.code}")
          .to_return(body: response, status: 200)
      end

      it 'returns an add-on' do
        add_on = resource.get(factory_add_on.code)

        expect(add_on.lago_id).to eq('this-is-lago-id')
        expect(add_on.name).to eq(factory_add_on.name)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/add_ons/#{factory_add_on.code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get(factory_add_on.code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#destroy' do
    context 'when add-on is successfully destroyed' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/add_ons/#{factory_add_on.code}")
          .to_return(body: response, status: 200)
      end

      it 'returns an add-on' do
        add_on = resource.destroy(factory_add_on.code)

        expect(add_on.lago_id).to eq('this-is-lago-id')
        expect(add_on.name).to eq(factory_add_on.name)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/add_ons/#{factory_add_on.code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy(factory_add_on.code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:response) do
      {
        'add_ons' => [
          {
            'lago_id' => 'this-is-lago-id',
            'name' => factory_add_on.name,
            'code' => factory_add_on.code,
            'amount_cents' => factory_add_on.amount_cents,
            'amount_currency' => factory_add_on.amount_currency,
            'description' => factory_add_on.description,
            'created_at' => '2022-04-29T08:59:51Z'
          }
        ],
        'meta': {
          'current_page' => 1,
          'next_page' => 2,
          'prev_page' => nil,
          'total_pages' => 7,
          'total_count' => 63
        }
      }.to_json
    end

    context 'when there is no options' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/add_ons')
          .to_return(body: response, status: 200)
      end

      it 'returns add-ons on the first page' do
        response = resource.get_all

        expect(response['add_ons'].first['lago_id']).to eq('this-is-lago-id')
        expect(response['add_ons'].first['name']).to eq(factory_add_on.name)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/add_ons?per_page=2&page=1')
          .to_return(body: response, status: 200)
      end

      it 'returns add-ons on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['add_ons'].first['lago_id']).to eq('this-is-lago-id')
        expect(response['add_ons'].first['name']).to eq(factory_add_on.name)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/add_ons')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
