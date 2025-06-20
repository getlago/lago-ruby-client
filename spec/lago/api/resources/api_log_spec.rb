# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::ApiLog do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:api_log_response) { load_fixture('api_log') }
  let(:api_log_request_id) { '8fae2f0e-fe8e-44d3-bbf7-1c552eba3a24' }

  describe '#get' do
    let(:endpoint) { "https://api.getlago.com/api/v1/api_logs/#{api_log_request_id}" }
    let(:not_found_response) do
      {
        'status' => 404,
        'error' => 'Not Found',
        'code' => 'api_log_not_found',
      }
    end

    context 'when api log is successfully fetched' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: api_log_response, status: 200)
      end

      it 'returns an api log' do
        api_log = resource.get(api_log_request_id)

        expect(api_log.request_id).to eq(api_log_request_id)
        expect(api_log.http_method).to eq('post')
      end
    end

    context 'when is not found' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: not_found_response.to_json, status: 404)
      end

      it 'raises an error' do
        expect { resource.get(api_log_request_id) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:endpoint) { "https://api.getlago.com/api/v1/api_logs#{options}" }
    let(:options) { '' }
    let(:api_logs_response) { load_fixture('api_logs_index') }
    let(:not_allowed_response) do
      {
        'status' => 405,
        'error' => 'Method Not Allowed',
        'code' => '',
      }
    end

    context 'when there is no options' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: api_logs_response, status: 200)
      end

      it 'returns api logs on the first page' do
        response = resource.get_all

        expect(response['api_logs'].first['request_id']).to eq('8fae2f0e-fe8e-44d3-bbf7-1c552eba3a24')
        expect(response['api_logs'].first['http_method']).to eq('post')
        expect(response['api_logs'].last['request_id']).to eq('65ec835e-43f4-40ad-a4bd-da663349d583')
        expect(response['api_logs'].last['http_method']).to eq('post')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      let(:options_hash) { { per_page: 2, page: 1 } }
      let(:options) { "?#{URI.encode_www_form(options_hash)}" }

      before do
        stub_request(:get, endpoint)
          .to_return(body: api_logs_response, status: 200)
      end

      it 'returns api logs on selected page' do
        response = resource.get_all(options_hash)

        expect(response['api_logs'].first['request_id']).to eq('8fae2f0e-fe8e-44d3-bbf7-1c552eba3a24')
        expect(response['api_logs'].first['http_method']).to eq('post')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: not_allowed_response.to_json, status: 405)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error Lago::Api::HttpError
      end
    end
  end

  [:create, :update, :destroy].each do |method|
    describe "##{method}" do
      it "does not have #{method}" do
        expect(resource.respond_to?(method)).to be(false)
      end
    end
  end
end
