# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Customers::Wallets::Metadata do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:customer_id) { 'customer-id-123' }
  let(:wallet_code) { 'wallet-id-123' }

  describe '#replace' do
    let(:metadata) { { 'foo' => 'bar', 'baz' => 'qux' } }
    let(:metadata_response) { { metadata: metadata }.to_json }

    before do
      stub_request(:post, "https://api.getlago.com/api/v1/customers/#{customer_id}/wallets/#{wallet_code}/metadata")
        .with(body: { metadata: metadata })
        .to_return(body: metadata_response, status: 200)
    end

    it 'returns metadata hash' do
      response = resource.replace(customer_id, wallet_code, metadata)

      expect(response).to eq(metadata)
    end
  end

  describe '#merge' do
    let(:metadata) { { 'foo' => 'qux' } }
    let(:metadata_response) { { metadata: metadata }.to_json }

    before do
      stub_request(:patch, "https://api.getlago.com/api/v1/customers/#{customer_id}/wallets/#{wallet_code}/metadata")
        .with(body: { metadata: metadata })
        .to_return(body: metadata_response, status: 200)
    end

    it 'returns metadata hash' do
      response = resource.merge(customer_id, wallet_code, metadata)

      expect(response).to eq(metadata)
    end
  end

  describe '#delete_all' do
    let(:metadata_response) { { metadata: nil }.to_json }

    before do
      stub_request(:delete, "https://api.getlago.com/api/v1/customers/#{customer_id}/wallets/#{wallet_code}/metadata")
        .to_return(body: metadata_response, status: 200)
    end

    it 'returns nil metadata' do
      response = resource.delete_all(customer_id, wallet_code)

      expect(response).to be_nil
    end
  end

  describe '#delete_key' do
    let(:key) { 'foo' }
    let(:remaining_metadata) { { 'baz' => 'qux' } }
    let(:metadata_response) { { metadata: remaining_metadata }.to_json }

    before do
      stub_request(:delete, "https://api.getlago.com/api/v1/customers/#{customer_id}/wallets/#{wallet_code}/metadata/#{key}")
        .to_return(body: metadata_response, status: 200)
    end

    it 'returns remaining metadata hash' do
      response = resource.delete_key(customer_id, wallet_code, key)

      expect(response).to eq(remaining_metadata)
    end
  end
end
