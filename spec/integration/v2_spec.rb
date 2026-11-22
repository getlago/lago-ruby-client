# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'

RSpec.describe 'API v2', :integration do
  let(:client) do
    Lago::Api::V2::Client.new(
      api_key: ENV.fetch('TEST_LAGO_API_KEY'),
      api_url: ENV.fetch('TEST_LAGO_API_URL'),
      retry_on_rate_limit: false,
    )
  end
  let(:prefix) { "ruby-v2-#{SecureRandom.hex(8)}" }

  it 'creates, retrieves, updates, patches, and deletes taxes' do
    tax = client.taxes.create(code: prefix, name: 'Ruby v2 smoke test', rate: 20, description: 'Temporary tax')
    expect(tax.code).to eq(prefix)
    expect(client.taxes.get(prefix).lago_id).to eq(tax.lago_id)
    expect(client.taxes.update({ name: 'Updated tax' }, prefix).name).to eq('Updated tax')
    expect(client.taxes.patch({ description: nil }, prefix).description).to be_nil
    expect(client.taxes.destroy(prefix).deleted_at).not_to be_nil
    tax = nil
  ensure
    client.taxes.destroy(prefix) if tax
  end

  it 'navigates tax cursors and requests total counts' do
    codes = []
    2.times do |index|
      code = "#{prefix}-#{index}"
      client.taxes.create(code:, name: 'Ruby v2 pagination test', rate: 10)
      codes << code
    end

    first = client.taxes.get_all(limit: 1, include_total_count: true)
    expect(first.taxes.length).to eq(1)
    expect(first.meta.total_count).to be >= 2
    expect(first.meta.next_cursor).not_to be_nil

    second = client.taxes.get_all(limit: 1, after: first.meta.next_cursor)
    expect(second.taxes.first.lago_id).not_to eq(first.taxes.first.lago_id)
    expect(second.meta.to_h).not_to have_key(:total_count)

    previous = client.taxes.get_all(limit: 1, before: second.meta.prev_cursor)
    expect(previous.taxes.first.lago_id).to eq(first.taxes.first.lago_id)
  ensure
    codes&.each { |code| client.taxes.destroy(code) }
  end

  it 'returns structured validation errors' do
    expect { client.taxes.create(code: prefix, name: '', rate: 20) }.to raise_error(Lago::Api::V2::HttpError) { |error|
      expect(error.http_status).to eq(422)
      expect(error.code).to be_a(String)
      expect(error.details).to include(include('field' => 'name'))
    }
  end

  it 'returns structured errors for unsupported pagination parameters' do
    expect { client.taxes.get_all(page: 1) }.to raise_error(Lago::Api::V2::HttpError) { |error|
      expect(error.http_status).to eq(400)
      expect(error.details).to be_an(Array)
    }
  end

  it 'retrieves supported customer expansions' do
    created = client.customers.create(external_id: prefix, name: 'Ruby v2 customer', currency: 'USD')

    customer = client.customers.get(created.external_id, expands: %w[taxes metadata])
    expect(customer.to_h).to include(:taxes, :metadata)
  ensure
    client.customers.destroy(prefix) if created
  end

  it 'creates product catalog resources and retrieves a nested rate collection' do
    product = client.products.create(code: prefix, name: 'Ruby v2 product', product_type: 'fixed')
    expect(product.code).to eq(prefix)
    expect(client.products.patch({ description: nil }, prefix).description).to be_nil

    card = client.rate_cards.create(code: prefix, name: 'Ruby v2 rate card', currency: 'USD', product_code: prefix)
    expect(card.code).to eq(prefix)
    rates = client.rate_card_rates(prefix).get_all
    expect(rates.rates).to eq([])
    expect(rates.to_h).not_to have_key(:meta)
  ensure
    client.rate_cards.destroy(prefix) if card
    client.products.destroy(prefix) if product
  end

  [
    :product_categories,
    :products,
    :rate_cards,
    :plans,
    :contracts,
    :invoices,
    :fees,
    :payments,
    :payment_requests,
    :payment_receipts,
    :credit_notes,
    :customers,
    :billing_entities,
    :billable_metrics,
    :webhook_endpoints,
  ].each do |name|
    it "lists #{name} with cursor pagination" do
      expect(client.public_send(name).get_all(limit: 1).to_h).to include(name, :meta)
    end
  end

  it 'retrieves the organization' do
    expect(client.organizations.get.lago_id).not_to be_nil
  end
end
