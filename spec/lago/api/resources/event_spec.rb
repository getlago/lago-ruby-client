# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Event do
  subject(:resource) { described_class.new(client) }
  let(:client) { Lago::Api::Client.new }
  let(:factory_event) { FactoryBot.build(:event) }
  let(:factory_batch_event) { FactoryBot.build(:batch_event) }

  describe '#create' do
    let(:params) { factory_event.to_h }
    let(:body) do
      {
        'event' => factory_event.to_h
      }
    end

    context 'when event is successfully processed' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/events')
          .with(body: body)
          .to_return(body: '', status: 200)
      end

      it 'returns true' do
        response = resource.create(params)

        expect(response).to be true
      end
    end
  end

  describe '#batch_create' do
    let(:params) { factory_batch_event.to_h }
    let(:body) do
      {
        'event' => factory_batch_event.to_h
      }
    end

    context 'when event is successfully processed' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/events/batch')
          .with(body: body)
          .to_return(body: '', status: 200)
      end

      it 'returns true' do
        response = resource.batch_create(params)

        expect(response).to be true
      end
    end
  end

  describe '#get' do
    context 'when the event exists' do
      before do
        event_json = JSON.generate({ 'event' => factory_event.to_h })

        stub_request(:get, 'https://api.getlago.com/api/v1/events/UNIQUE_ID')
          .to_return(body: event_json, status: 200)
      end

      it 'returns the matching event if it exists' do
        response = resource.get(factory_event.transaction_id)

        expect(response.transaction_id).to eq factory_event.transaction_id
      end
    end

    context 'when the event does not exist' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/events/DOESNOTEXIST')
          .to_return(body: JSON.generate({ status: 404, error: 'Not Found' }), status: 404)
      end

      it 'raises an error' do
        expect { resource.get('DOESNOTEXIST') }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
