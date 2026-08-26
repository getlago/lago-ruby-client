# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::QuoteVersion do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:quote_version_response) { load_fixture('quote_version') }
  let(:quote_version_id) { JSON.parse(quote_version_response)['quote_version']['lago_id'] }
  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#get' do
    let(:endpoint) { "https://api.getlago.com/api/v1/quote_versions/#{quote_version_id}" }

    context 'when quote version is successfully fetched' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: quote_version_response, status: 200)
      end

      it 'returns a quote version' do
        quote_version = resource.get(quote_version_id)

        expect(quote_version.lago_id).to eq(quote_version_id)
        expect(quote_version.version).to eq(1)
        expect(quote_version.status).to eq('draft')
        expect(quote_version.void_reason).to be_nil
        expect(quote_version.content).to include('QT-2026-0001')
        expect(quote_version.billing_items.plans.first.payload.code).to eq('premium_plan')
        expect(quote_version.billing_items.walletCredits.first.payload.paidCredits).to eq('100.0')
      end
    end

    context 'when is not found' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: { 'status' => 404, 'error' => 'Not Found' }.to_json, status: 404)
      end

      it 'raises an error' do
        expect { resource.get(quote_version_id) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#approve' do
    let(:endpoint) { "https://api.getlago.com/api/v1/quote_versions/#{quote_version_id}/approve" }

    context 'when no params are given' do
      before do
        stub_request(:post, endpoint)
          .with(body: {})
          .to_return(body: quote_version_response, status: 200)
      end

      it 'returns the quote version' do
        quote_version = resource.approve(quote_version_id)

        expect(quote_version.lago_id).to eq(quote_version_id)
      end
    end

    context 'when expires_at is given' do
      let(:params) { { expires_at: '2026-06-30T23:59:59Z' } }

      before do
        stub_request(:post, endpoint)
          .with(body: params)
          .to_return(body: quote_version_response, status: 200)
      end

      it 'returns the quote version' do
        quote_version = resource.approve(quote_version_id, params)

        expect(quote_version.lago_id).to eq(quote_version_id)
      end
    end

    context 'when the version cannot be approved' do
      before do
        stub_request(:post, endpoint)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.approve(quote_version_id) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#void' do
    let(:endpoint) { "https://api.getlago.com/api/v1/quote_versions/#{quote_version_id}/void" }

    before do
      stub_request(:post, endpoint)
        .with(body: {})
        .to_return(body: quote_version_response, status: 200)
    end

    it 'returns the quote version' do
      quote_version = resource.void(quote_version_id)

      expect(quote_version.lago_id).to eq(quote_version_id)
    end
  end

  describe '#clone' do
    let(:endpoint) { "https://api.getlago.com/api/v1/quote_versions/#{quote_version_id}/clone" }

    before do
      stub_request(:post, endpoint)
        .with(body: {})
        .to_return(body: quote_version_response, status: 200)
    end

    it 'returns the quote version' do
      quote_version = resource.clone(quote_version_id)

      expect(quote_version.lago_id).to eq(quote_version_id)
    end
  end
end
