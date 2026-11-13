# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::V2::Client do
  let(:client) { described_class.new(api_key: 'test-key') }

  describe '#base_api_url' do
    it 'defaults to the US v2 endpoint' do
      expect(client.base_api_url.to_s).to eq('https://api.getlago.com/api/v2/')
    end

    it 'supports the EU endpoint' do
      eu_client = described_class.new(api_url: 'https://api.eu.getlago.com')
      expect(eu_client.base_api_url.to_s).to eq('https://api.eu.getlago.com/api/v2/')
    end

    it 'supports custom HTTP endpoints and path prefixes' do
      local_client = described_class.new(api_url: 'http://localhost:3000/lago/')
      expect(local_client.base_api_url.to_s).to eq('http://localhost:3000/lago/api/v2/')
    end
  end

  it 'keeps the v1 client on its existing endpoint' do
    expect(Lago::Api::Client.new.base_api_url.to_s).to eq('https://api.getlago.com/api/v1/')
  end

  it 'does not expose resources or actions absent from the v2 specification' do
    expect(client).not_to respond_to(:wallets, :subscriptions, :coupons)
    expect(client.plans).not_to respond_to(:destroy)
    expect(client.invoices).not_to respond_to(:create)
    expect(client.plan_rate_phases('plan', 'card')).not_to respond_to(:get)
  end

  it 'provides catalog_plans as an alias for plans' do
    expect(client.catalog_plans).to be_a(Lago::Api::V2::Resources::CatalogPlan)
  end

  it 'sends requests to the configured endpoint' do
    local_client = described_class.new(api_key: 'local-key', api_url: 'http://localhost:3000/lago/')
    request = stub_request(:get, 'http://localhost:3000/lago/api/v2/taxes/vat')
      .with(headers: { 'Authorization' => 'Bearer local-key' })
      .to_return(status: 200, body: { tax: { code: 'vat' } }.to_json)

    expect(local_client.taxes.get('vat').code).to eq('vat')
    expect(request).to have_been_requested.once
  end
end
