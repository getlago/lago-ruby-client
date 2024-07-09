# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::BillableMetric do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:billable_metric_response) { load_fixture('billable_metric') }
  let(:billable_metric_code) { 'bm_code' }

  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#create' do
    let(:filters) do
      {
        key: 'country',
        values: %w[france italy spain],
      }
    end

    let(:params) { create(:create_billable_metric).to_h.merge(filters: [filters.to_h]) }

    context 'when billable metric is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/billable_metrics')
          .with(body: { billable_metric: params })
          .to_return(body: billable_metric_response, status: 200)
      end

      it 'returns an billable metric' do
        billable_metric = resource.create(params)

        expect(billable_metric.lago_id).to eq('b7ab2926-1de8-4428-9bcd-779314ac129b')
        expect(billable_metric.name).to eq('bm_name')
        expect(billable_metric.filters.map(&:to_h)).to eq([filters.to_h])
        expect(billable_metric.weighted_interval).to be_nil
      end
    end

    context 'when billable_metric failed to create' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/billable_metrics')
          .with(body: { billable_metric: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#update' do
    let(:params) { create(:update_billable_metric).to_h }

    context 'when billable metric is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/billable_metrics/#{billable_metric_code}")
          .with(body: { billable_metric: params })
          .to_return(body: billable_metric_response, status: 200)
      end

      it 'returns an billable metric' do
        billable_metric = resource.update(params, billable_metric_code)

        expect(billable_metric.lago_id).to eq('b7ab2926-1de8-4428-9bcd-779314ac129b')
        expect(billable_metric.name).to eq('bm_name')
      end
    end

    context 'when billable_metric failed to update' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/billable_metrics/#{billable_metric_code}")
          .with(body: { billable_metric: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, billable_metric_code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get' do
    context 'when billable metric is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/billable_metrics/#{billable_metric_code}")
          .to_return(body: billable_metric_response, status: 200)
      end

      it 'returns an billable metric' do
        billable_metric = resource.get(billable_metric_code)

        expect(billable_metric.lago_id).to eq('b7ab2926-1de8-4428-9bcd-779314ac129b')
        expect(billable_metric.name).to eq('bm_name')
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/billable_metrics/#{billable_metric_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get(billable_metric_code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#destroy' do
    context 'when billable metric is successfully destroyed' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/billable_metrics/#{billable_metric_code}")
          .to_return(body: billable_metric_response, status: 200)
      end

      it 'returns an billable metric' do
        billable_metric = resource.destroy(billable_metric_code)

        expect(billable_metric.lago_id).to eq('b7ab2926-1de8-4428-9bcd-779314ac129b')
        expect(billable_metric.name).to eq('bm_name')
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/billable_metrics/#{billable_metric_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy(billable_metric_code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:billable_metrics_response) { load_fixture('billable_metric_index') }

    context 'when there is no options' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/billable_metrics')
          .to_return(body: billable_metrics_response, status: 200)
      end

      it 'returns billable metrics on the first page' do
        response = resource.get_all

        expect(response['billable_metrics'].first['lago_id']).to eq('b7ab2926-1de8-4428-9bcd-779314ac1000')
        expect(response['billable_metrics'].first['name']).to eq('bm_name')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/billable_metrics?per_page=2&page=1')
          .to_return(body: billable_metrics_response, status: 200)
      end

      it 'returns billable metrics on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['billable_metrics'].first['lago_id']).to eq('b7ab2926-1de8-4428-9bcd-779314ac1000')
        expect(response['billable_metrics'].first['name']).to eq('bm_name')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/billable_metrics')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
