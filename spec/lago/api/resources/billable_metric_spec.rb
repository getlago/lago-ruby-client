# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::BillableMetric do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:factory_billable_metric) { FactoryBot.build(:billable_metric) }
  let(:response) do
    {
      'billable_metric' => {
        'lago_id' => 'this-is-lago-id',
        'name' => factory_billable_metric.name,
        'code' => factory_billable_metric.code,
        'description' => factory_billable_metric.description,
        'aggregation_type' => factory_billable_metric.aggregation_type,
        'field_name' => factory_billable_metric.field_name,
        'created_at' => '2022-04-29T08:59:51Z'
      }
    }.to_json
  end

  describe '#create' do
    let(:params) { factory_billable_metric.to_h }
    let(:body) do
      {
        'billable_metric' => factory_billable_metric.to_h
      }
    end

    context 'when billable metric is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/billable_metrics')
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns an billable metric' do
        billable_metric = resource.create(params)

        expect(billable_metric.lago_id).to eq('this-is-lago-id')
        expect(billable_metric.name).to eq(factory_billable_metric.name)
      end
    end

    context 'when billable_metric failed to create' do
      let(:response) do
        {
          'status' => 422,
          'error' => 'Unprocessable Entity',
          'message' => 'Validation error on the record'
        }.to_json
      end

      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/billable_metrics')
          .with(body: body)
          .to_return(body: response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#update' do
    let(:params) { factory_billable_metric.to_h }
    let(:body) do
      {
        'billable_metric' => factory_billable_metric.to_h
      }
    end

    context 'when billable metric is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/billable_metrics/#{factory_billable_metric.code}")
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns an billable metric' do
        billable_metric = resource.update(params, factory_billable_metric.code)

        expect(billable_metric.lago_id).to eq('this-is-lago-id')
        expect(billable_metric.name).to eq(factory_billable_metric.name)
      end
    end

    context 'when billable_metric failed to update' do
      let(:response) do
        {
          'status' => 422,
          'error' => 'Unprocessable Entity',
          'message' => 'Validation error on the record'
        }.to_json
      end

      before do
        stub_request(:put, "https://api.getlago.com/api/v1/billable_metrics/#{factory_billable_metric.code}")
          .with(body: body)
          .to_return(body: response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, factory_billable_metric.code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get' do
    context 'when billable metric is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/billable_metrics/#{factory_billable_metric.code}")
          .to_return(body: response, status: 200)
      end

      it 'returns an billable metric' do
        billable_metric = resource.get(factory_billable_metric.code)

        expect(billable_metric.lago_id).to eq('this-is-lago-id')
        expect(billable_metric.name).to eq(factory_billable_metric.name)
      end
    end

    context 'when there is an issue' do
      let(:response) do
        {
          'status' => 422,
          'error' => 'Unprocessable Entity',
          'message' => 'Validation error on the record'
        }.to_json
      end

      before do
        stub_request(:get, "https://api.getlago.com/api/v1/billable_metrics/#{factory_billable_metric.code}")
          .to_return(body: response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get(factory_billable_metric.code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#destroy' do
    context 'when billable metric is successfully destroyed' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/billable_metrics/#{factory_billable_metric.code}")
          .to_return(body: response, status: 200)
      end

      it 'returns an billable metric' do
        billable_metric = resource.destroy(factory_billable_metric.code)

        expect(billable_metric.lago_id).to eq('this-is-lago-id')
        expect(billable_metric.name).to eq(factory_billable_metric.name)
      end
    end

    context 'when there is an issue' do
      let(:response) do
        {
          'status' => 422,
          'error' => 'Unprocessable Entity',
          'message' => 'Validation error on the record'
        }.to_json
      end

      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/billable_metrics/#{factory_billable_metric.code}")
          .to_return(body: response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy(factory_billable_metric.code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:response) do
      {
        'billable_metrics' => [
          {
            'lago_id' => 'this-is-lago-id',
            'name' => factory_billable_metric.name,
            'code' => factory_billable_metric.code,
            'description' => factory_billable_metric.description,
            'aggregation_type' => factory_billable_metric.aggregation_type,
            'field_name' => factory_billable_metric.field_name,
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
        stub_request(:get, 'https://api.getlago.com/api/v1/billable_metrics')
          .to_return(body: response, status: 200)
      end

      it 'returns an billable metrics on the first page' do
        response = resource.get_all

        expect(response['billable_metrics'].first['lago_id']).to eq('this-is-lago-id')
        expect(response['billable_metrics'].first['name']).to eq(factory_billable_metric.name)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/billable_metrics?per_page=2&page=1')
          .to_return(body: response, status: 200)
      end

      it 'returns an billable metrics on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['billable_metrics'].first['lago_id']).to eq('this-is-lago-id')
        expect(response['billable_metrics'].first['name']).to eq(factory_billable_metric.name)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      let(:response) do
        {
          'status' => 422,
          'error' => 'Unprocessable Entity',
          'message' => 'Validation error on the record'
        }.to_json
      end

      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/billable_metrics')
          .to_return(body: response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
