# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Client do
  subject(:client) do
    described_class.new(
      api_key: '123456',
      api_url: api_url,
    )
  end

  let(:api_url) { 'http://test.api.url/' }

  describe '#base_api_url' do
    context 'when api_url is given' do
      it { expect(client.base_api_url).to eq(URI("#{api_url}api/v1/")) }
    end

    context 'when api_url is NOT given' do
      let(:api_url) { nil }

      it { expect(client.base_api_url).to eq(URI('https://api.getlago.com/api/v1/')) }
    end
  end

  describe '#base_ingest_api_url' do
    subject(:client) do
      described_class.new(
        api_key: '123456',
        api_url: api_url,
        use_ingest_service: use_ingest_service,
        ingest_api_url: ingest_api_url,
      )
    end

    let(:use_ingest_service) { false }
    let(:ingest_api_url) { nil }

    context 'when use_ingest_service flag is false' do
      it { expect(client.base_ingest_api_url).to eq(URI("#{api_url}api/v1/")) }
    end

    context 'when use_ingest_service flag is true' do
      let(:use_ingest_service) { true }

      it { expect(client.base_ingest_api_url).to eq(URI('https://ingest.getlago.com/api/v1/')) }

      context 'when a base_ingest_url is provided' do
        let(:ingest_api_url) { 'http://ingest.api.url/' }

        it { expect(client.base_ingest_api_url).to eq(URI("#{ingest_api_url}api/v1/")) }
      end
    end
  end
end
