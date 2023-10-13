# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Event do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:event_response) { load_fixture('event') }

  describe '#create' do
    let(:params) { create(:event).to_h }

    context 'when event is successfully processed' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/events')
          .with(body: { event: params })
          .to_return(body: event_response, status: 200)
      end

      it 'returns true' do
        event = resource.create(params)

        expect(event.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
      end
    end
  end

  describe '#batch_create' do
    let(:params) { build(:batch_event).to_h }

    context 'when event is successfully processed' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/events/batch')
          .with(body: { event: params })
          .to_return(body: '', status: 200)
      end

      it 'returns true' do
        response = resource.batch_create(params)

        expect(response).to be true
      end
    end
  end

  describe '#get' do
    let(:event_id) { '1a901a90-1a90-1a90-1a90-1a901a901a90"' }

    context 'when the event exists' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/events/#{event_id}")
          .to_return(body: event_response, status: 200)
      end

      it 'returns the matching event if it exists' do
        response = resource.get(event_id)

        expect(response.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
      end
    end

    context 'when the event does not exist' do
      let(:event_id) { 'DOESNOTEXIST' }

      before do
        stub_request(:get, "https://api.getlago.com/api/v1/events/#{event_id}")
          .to_return(body: JSON.generate({ status: 404, error: 'Not Found' }), status: 404)
      end

      it 'raises an error' do
        expect { resource.get(event_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#estimate_fees' do
    let(:factory_event) { build(:estimate_fees_event) }
    let(:event_body) { { 'event' => factory_event.to_h } }

    let(:fees_response) { { fees: [JSON.parse(load_fixture('fee'))['fee']] }.to_json }

    context 'when event is successfully processed' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/events/estimate_fees')
          .with(body: event_body)
          .to_return(body: fees_response, status: 200)
      end

      it 'returns a list of fees' do
        response = resource.estimate_fees(factory_event.to_h)

        expect(response['fees'].count).to eq(1)
      end
    end
  end
end
