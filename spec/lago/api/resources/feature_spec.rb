# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Feature do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:response) do
    {
      'feature' => {
        'worked' => true,
      },
    }.to_json
  end

  describe '#create' do
    let(:params) { { code: 'seats', ignored: true } }
    let(:body) do
      {
        'feature' => { code: 'seats' },
      }
    end

    context 'when feature is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/features')
          .with(body:)
          .to_return(body: response, status: 200)
      end

      it 'returns an feature' do
        feature = resource.create(params)

        expect(feature.worked).to be true
      end
    end
  end

  describe '#update' do
    let(:params) { { code: 'seats', name: 'Name' } }
    let(:body) do
      {
        'feature' => params,
      }
    end

    context 'when feature is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/features/#{params[:code]}")
          .with(body:)
          .to_return(body: response, status: 200)
      end

      it 'returns an feature' do
        feature = resource.update(params, 'seats')

        expect(feature.worked).to be true
      end
    end
  end

  describe '#get' do
    context 'when feature is successfully fetched' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/features/seats')
          .to_return(body: response, status: 200)
      end

      it 'returns an feature' do
        feature = resource.get('seats')

        expect(feature.worked).to be true
      end
    end
  end

  describe '#destroy' do
    context 'when feature is successfully destroyed' do
      before do
        stub_request(:delete, 'https://api.getlago.com/api/v1/features/seats')
          .to_return(body: response, status: 200)
      end

      it 'returns an feature' do
        feature = resource.destroy('seats')

        expect(feature.worked).to be true
      end
    end
  end

  describe '#get_all' do
    let(:response) do
      {
        'features' => [
          {
            worked: true,
          },
        ],
      }.to_json
    end

    context 'when there is no options' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/features')
          .to_return(body: response, status: 200)
      end

      it 'returns features on the first page' do
        response = resource.get_all

        expect(response['features'].first['worked']).to be(true)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/features?per_page=2&page=1')
          .to_return(body: response, status: 200)
      end

      it 'returns features on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['features'].first['worked']).to be(true)
      end
    end
  end
end
