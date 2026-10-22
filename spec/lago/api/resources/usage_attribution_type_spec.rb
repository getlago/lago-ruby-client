# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::UsageAttributionType do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:usage_attribution_type_response) { load_fixture('usage_attribution_type') }
  let(:usage_attribution_type_code) { JSON.parse(usage_attribution_type_response)['usage_attribution_type']['code'] }

  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#create' do
    let(:params) { create(:create_usage_attribution_type).to_h }

    context 'when usage attribution type is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/usage_attribution_types')
          .with(body: { usage_attribution_type: params })
          .to_return(body: usage_attribution_type_response, status: 200)
      end

      it 'returns a usage attribution type' do
        usage_attribution_type = resource.create(params)

        expect(usage_attribution_type.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
        expect(usage_attribution_type.name).to eq('Team')
      end
    end

    context 'when usage attribution type failed to create' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/usage_attribution_types')
          .with(body: { usage_attribution_type: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#update' do
    let(:params) { create(:create_usage_attribution_type).to_h }

    context 'when usage attribution type is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/usage_attribution_types/#{usage_attribution_type_code}")
          .with(body: { usage_attribution_type: params })
          .to_return(body: usage_attribution_type_response, status: 200)
      end

      it 'returns a usage attribution type' do
        response = resource.update(params, usage_attribution_type_code)

        expect(response.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
        expect(response.name).to eq('Team')
      end
    end

    context 'when parent_code is set to nil' do
      let(:params) { { name: 'Team', parent_code: nil } }

      before do
        stub_request(:put, "https://api.getlago.com/api/v1/usage_attribution_types/#{usage_attribution_type_code}")
          .with(body: { usage_attribution_type: { name: 'Team', parent_code: nil } })
          .to_return(body: usage_attribution_type_response, status: 200)
      end

      it 'sends the nil parent_code to detach the parent' do
        response = resource.update(params, usage_attribution_type_code)

        expect(response.code).to eq('team')
      end
    end

    context 'when usage attribution type failed to update' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/usage_attribution_types/#{usage_attribution_type_code}")
          .with(body: { usage_attribution_type: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, usage_attribution_type_code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get' do
    context 'when usage attribution type is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/usage_attribution_types/#{usage_attribution_type_code}")
          .to_return(body: usage_attribution_type_response, status: 200)
      end

      it 'returns a usage attribution type' do
        response = resource.get(usage_attribution_type_code)

        expect(response.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
        expect(response.name).to eq('Team')
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/usage_attribution_types/#{usage_attribution_type_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get(usage_attribution_type_code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#destroy' do
    context 'when usage attribution type is successfully destroyed' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/usage_attribution_types/#{usage_attribution_type_code}")
          .to_return(body: usage_attribution_type_response, status: 200)
      end

      it 'returns a usage attribution type' do
        response = resource.destroy(usage_attribution_type_code)

        expect(response.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/usage_attribution_types/#{usage_attribution_type_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy(usage_attribution_type_code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:usage_attribution_types_response) { load_fixture(:usage_attribution_types) }

    context 'when there is no options' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/usage_attribution_types')
          .to_return(body: usage_attribution_types_response, status: 200)
      end

      it 'returns usage attribution types on the first page' do
        response = resource.get_all

        expect(response['usage_attribution_types'].first['lago_id']).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
        expect(response['usage_attribution_types'].first['name']).to eq('Team')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/usage_attribution_types?per_page=2&page=1')
          .to_return(body: usage_attribution_types_response, status: 200)
      end

      it 'returns usage attribution types on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['usage_attribution_types'].first['lago_id']).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
        expect(response['usage_attribution_types'].first['name']).to eq('Team')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/usage_attribution_types')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
