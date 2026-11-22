# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::V2::Resources::Base do
  let(:client) { Lago::Api::V2::Client.new(api_key: 'test-key') }

  it 'encodes customer identifiers as a single path segment' do
    request = stub_request(:get, 'https://api.getlago.com/api/v2/customers/acme%2Fus%20%2B%3F%23%25')
      .to_return(status: 200, body: { customer: { external_id: 'acme/us +?#%' } }.to_json)

    expect(client.customers.get('acme/us +?#%').external_id).to eq('acme/us +?#%')
    expect(request).to have_been_requested.once
  end

  it 'encodes each parent and child identifier in nested resources' do
    request = stub_request(
      :patch,
      'https://api.getlago.com/api/v2/contracts/acme%2Fus/applied_rate_cards/card%20one/rate_phases/phase%2F1',
    ).with(body: { rate_phase: { duration: nil } }.to_json)
      .to_return(status: 200, body: { rate_phase: { duration: nil } }.to_json)

    result = client.contract_rate_phases('acme/us', 'card one').patch({ duration: nil }, 'phase/1')

    expect(result.duration).to be_nil
    expect(request).to have_been_requested.once
  end

  it 'rejects missing or empty identifiers before sending a request' do
    expect { client.customers.get(nil) }.to raise_error(ArgumentError)
    expect { client.taxes.destroy('') }.to raise_error(ArgumentError)
    expect { client.product_filters(nil).get_all }.to raise_error(ArgumentError)
  end

  it 'preserves false, null, empty arrays, and empty objects in update bodies' do
    params = { description: nil, invoice_grace_period: 0, finalize_zero_amount_invoice: false, metadata: [], extra: {} }
    request = stub_request(:patch, 'https://api.getlago.com/api/v2/customers/acme')
      .with(body: { customer: params }.to_json)
      .to_return(status: 200, body: { customer: { external_id: 'acme', description: nil } }.to_json)

    client.customers.patch(params, 'acme')

    expect(params).not_to have_key(:name)
    expect(request).to have_been_requested.once
  end

  it 'supports string keys and keeps the input hash unchanged' do
    params = { 'name' => 'Acme', 'description' => nil }.freeze
    request = stub_request(:put, 'https://api.getlago.com/api/v2/products/storage')
      .with(body: { product: params }.to_json)
      .to_return(status: 200, body: { product: { code: 'storage' } }.to_json)

    expect(client.products.update(params, 'storage').code).to eq('storage')
    expect(request).to have_been_requested.once
  end

  it 'encodes repeated arrays, metadata filters, false values, and opaque cursors' do
    options = {
      after: 'eyJpZCI6IisvPSJ9',
      limit: 2,
      include_total_count: false,
      has_customer_type: false,
      metadata: { reference: '', team: 'a&b' },
      'currencies[]' => %w[EUR USD],
      countries: %w[FR US],
      search_term: nil,
    }
    request = stub_request(:get, 'https://api.getlago.com/api/v2/customers').with(
      query: {
        'after' => 'eyJpZCI6IisvPSJ9',
        'limit' => '2',
        'include_total_count' => 'false',
        'has_customer_type' => 'false',
        'metadata[reference]' => '',
        'metadata[team]' => 'a&b',
        'currencies' => %w[EUR USD],
        'countries' => %w[FR US],
      },
    ).to_return(status: 200, body: { customers: [], meta: { next_cursor: nil, prev_cursor: nil } }.to_json)

    page = client.customers.get_all(options)

    expect(page.customers).to eq([])
    expect(page.meta.to_h).to eq(next_cursor: nil, prev_cursor: nil)
    expect(request).to have_been_requested.once
  end

  it 'returns count metadata only when it is present in the response' do
    stub_request(:get, 'https://api.getlago.com/api/v2/taxes?include_total_count=true')
      .to_return(
        status: 200,
        body: {
          taxes: [],
          meta: { next_cursor: nil, prev_cursor: nil, total_count: 42, total_count_estimated: true },
        }.to_json,
      )

    page = client.taxes.get_all(include_total_count: true)

    expect(page.meta.total_count).to eq(42)
    expect(page.meta.total_count_estimated).to be(true)
  end

  it 'preserves expanded relationships, decimal strings, and timestamp precision' do
    timestamp = '2026-11-13T12:34:56.123456Z'
    request = stub_request(:get, 'https://api.getlago.com/api/v2/invoices/invoice-1')
      .with(query: { 'expands' => %w[customer fees] })
      .to_return(
        status: 200,
        body: {
          invoice: {
            lago_id: 'invoice-1',
            created_at: timestamp,
            deleted_at: nil,
            customer: { external_id: 'acme' },
            fees: [{ precise_amount: '12.34567890123456789' }],
          },
        }.to_json,
      )

    invoice = client.invoices.get('invoice-1', expands: %w[customer fees])

    expect(invoice.created_at).to eq(timestamp)
    expect(invoice.customer.external_id).to eq('acme')
    expect(invoice.fees.first.precise_amount).to eq('12.34567890123456789')
    expect(invoice.to_h).not_to have_key(:payments)
    expect(request).to have_been_requested.once
  end

  it 'retains the envelope for collections that have no pagination' do
    stub_request(:get, 'https://api.getlago.com/api/v2/rate_cards/storage/rates')
      .to_return(status: 200, body: { rates: [{ code: 'base' }] }.to_json)

    result = client.rate_card_rates('storage').get_all

    expect(result.rates.first.code).to eq('base')
    expect(result.to_h).not_to have_key(:meta)
  end

  it 'wraps batch events once and returns the event array' do
    events = [
      {
        transaction_id: 'tx-1',
        code: 'storage',
        external_contract_id: 'contract-1',
        properties: { gb: '1.25' },
      },
    ]
    request = stub_request(:post, 'https://api.getlago.com/api/v2/events/batch')
      .with(body: { events: }.to_json)
      .to_return(status: 200, body: { events: [{ transaction_id: 'tx-1' }] }.to_json)

    expect(client.events.create_batch(events).first.transaction_id).to eq('tx-1')
    expect(request).to have_been_requested.once
  end

  it 'keeps the payment method selection inside the retry payment body' do
    request = stub_request(:post, 'https://api.getlago.com/api/v2/invoices/invoice-1/retry_payment')
      .with(body: { payment_method: { payment_method_id: 'pm-1' } }.to_json)
      .to_return(status: 200, body: '')

    expect(client.invoices.retry_payment('invoice-1', payment_method: { payment_method_id: 'pm-1' })).to be_nil
    expect(request).to have_been_requested.once
  end

  it 'supports empty metadata and nullable metadata responses' do
    request = stub_request(:post, 'https://api.getlago.com/api/v2/credit_notes/cn-1/metadata')
      .with(body: { metadata: {} }.to_json)
      .to_return(status: 200, body: { metadata: nil }.to_json)

    expect(client.credit_notes.replace_metadata('cn-1', {})).to be_nil
    expect(request).to have_been_requested.once
  end

  it 'encodes metadata keys as path segments' do
    request = stub_request(:delete, 'https://api.getlago.com/api/v2/credit_notes/cn-1/metadata/team%2Fname')
      .to_return(status: 200, body: { metadata: { reference: 'ok' } }.to_json)

    expect(client.credit_notes.destroy_metadata_key('cn-1', 'team/name').reference).to eq('ok')
    expect(request).to have_been_requested.once
  end
end
