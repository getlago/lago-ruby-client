# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Event do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:event_response) { load_fixture('event') }

  def expect_to_match_fixture(event)
    expect(event.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
    expect(event.lago_id).to eq '1a901a90-1a90-1a90-1a90-1a901a901a90'
    expect(event.transaction_id).to eq '1a901a90-1a90-1a90-1a90-1a901a901a90'
    expect(event.lago_customer_id).to eq '1a901a90-1a90-1a90-1a90-1a901a901a90'
    expect(event.code).to eq 'bm_code'
    expect(event.timestamp).to eq '2022-04-29T08:59:51.998Z'
    expect(event.precise_total_amount_cents).to be_nil
    expect(event.properties.custom_field).to eq 12
    expect(event.lago_subscription_id).to eq '1a901a90-1a90-1a90-1a90-1a901a901a90'
    expect(event.external_subscription_id).to eq '1a901a90-1a90-1a90-1a90-1a901a901a90'
    expect(event.created_at).to eq '2022-04-29T08:59:51Z'
  end

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
        expect_to_match_fixture(event)
      end
    end

    context 'when ingest url is used' do
      let(:client) { Lago::Api::Client.new(use_ingest_service: true) }

      before do
        stub_request(:post, 'https://ingest.getlago.com/api/v1/events')
          .with(body: { event: params })
          .to_return(body: event_response, status: 200)
      end

      it 'returns true' do
        event = resource.create(params)

        expect_to_match_fixture(event)
      end
    end
  end

  describe '#batch_create' do
    let(:params) { build(:batch_event).to_h }
    let(:events_response) { load_fixture('events') }

    context 'when event is successfully processed' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/events/batch')
          .with(body: params)
          .to_return(body: events_response, status: 200)
      end

      it 'returns true' do
        response = resource.batch_create(params)

        expect(response.events.count).to eq(1)
        expect_to_match_fixture(response.events.first)
      end
    end
  end

  describe '#get_all' do
    let(:events_response) { load_fixture('events') }

    context 'when events are successfully fetched' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/events')
          .to_return(body: events_response, status: 200)
      end

      it 'returns a list of events' do
        response = resource.get_all

        expect(response.events.count).to eq(1)
        expect_to_match_fixture(response.events.first)
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

        expect_to_match_fixture(response)
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
