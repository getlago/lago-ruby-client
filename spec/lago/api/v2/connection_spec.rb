# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::V2::Connection do
  let(:client) { Lago::Api::V2::Client.new(api_key: 'test-key', retry_on_rate_limit: false) }
  let(:error_body) do
    {
      code: 'validation_errors',
      details: [{ code: 'value_is_mandatory', field: 'name', meta: { min_length: 1 } }],
    }.to_json
  end

  [400, 401, 403, 404, 422, 500].each do |status|
    it "retains the HTTP status and structured error details for #{status}" do
      stub_request(:get, 'https://api.getlago.com/api/v2/taxes/vat')
        .to_return(status:, body: error_body)

      expect { client.taxes.get('vat') }.to raise_error(Lago::Api::V2::HttpError) { |error|
        expect(error).to be_a(Lago::Api::HttpError)
        expect(error.http_status).to eq(status)
        expect(error.error_code).to eq(status)
        expect(error.code).to eq('validation_errors')
        expect(error.details).to eq(
          [
            {
              'code' => 'value_is_mandatory',
              'field' => 'name',
              'meta' => { 'min_length' => 1 },
            },
          ],
        )
        expect(error.uri.to_s).to eq('https://api.getlago.com/api/v2/taxes/vat')
      }
    end
  end

  it 'keeps non-JSON error bodies available without losing the HTTP error' do
    stub_request(:get, 'https://api.getlago.com/api/v2/taxes/vat').to_return(status: 502, body: 'Bad gateway')

    expect { client.taxes.get('vat') }.to raise_error(Lago::Api::V2::HttpError) { |error|
      expect(error.http_status).to eq(502)
      expect(error.error_body).to eq('Bad gateway')
      expect(error.code).to be_nil
      expect(error.details).to eq([])
    }
  end

  it 'exposes rate-limit headers and the v2 error body when retries are disabled' do
    stub_request(:get, 'https://api.getlago.com/api/v2/taxes/vat').to_return(
      status: 429,
      body: { code: 'rate_limit_exceeded', details: [] }.to_json,
      headers: { 'x-ratelimit-limit' => '100', 'x-ratelimit-remaining' => '0', 'x-ratelimit-reset' => '2' },
    )

    expect { client.taxes.get('vat') }.to raise_error(Lago::Api::V2::RateLimitError) { |error|
      expect(error).to be_a(Lago::Api::RateLimitError)
      expect(error.http_status).to eq(429)
      expect(error.code).to eq('rate_limit_exceeded')
      expect(error.details).to eq([])
      expect([error.limit, error.remaining, error.reset]).to eq([100, 0, 2])
    }
  end

  it 'retries with the same request body and honors the configured attempt limit' do
    delays = []
    retry_client = Lago::Api::V2::Client.new(api_key: 'test-key', max_retries: 1)
    request = stub_request(:patch, 'https://api.getlago.com/api/v2/taxes/vat')
      .with(body: { tax: { description: nil } }.to_json)
      .to_return(status: 429, body: error_body, headers: { 'x-ratelimit-reset' => '2' })
      .then.to_return(status: 200, body: { tax: { code: 'vat', description: nil } }.to_json)
    allow(described_class).to receive(:new).and_wrap_original do |original, *args, **options|
      connection = original.call(*args, **options)
      allow(connection).to receive(:sleep) { |delay| delays << delay }
      connection
    end

    expect(retry_client.taxes.patch({ description: nil }, 'vat').code).to eq('vat')
    expect(delays).to eq([2])
    expect(request).to have_been_requested.twice
  end

  it 'raises a rate-limit error after the configured retries are exhausted' do
    retry_client = Lago::Api::V2::Client.new(max_retries: 1)
    request = stub_request(:get, 'https://api.getlago.com/api/v2/taxes/vat')
      .to_return(status: 429, body: error_body)
    allow(described_class).to receive(:new).and_wrap_original do |original, *args, **options|
      connection = original.call(*args, **options)
      allow(connection).to receive(:sleep)
      connection
    end

    expect { retry_client.taxes.get('vat') }.to raise_error(Lago::Api::V2::RateLimitError)
    expect(request).to have_been_requested.twice
  end

  it 'reports rate-limit information with the full v2 request URL' do
    observations = []
    observed_client = Lago::Api::V2::Client.new(on_rate_limit_info: ->(info) { observations << info })
    stub_request(:get, 'https://api.getlago.com/api/v2/taxes?limit=2').to_return(
      status: 200,
      body: { taxes: [], meta: { next_cursor: nil, prev_cursor: nil } }.to_json,
      headers: { 'x-ratelimit-limit' => '100', 'x-ratelimit-remaining' => '90' },
    )

    observed_client.taxes.get_all(limit: 2)

    expect(observations.length).to eq(1)
    expect(observations.first.method).to eq('GET')
    expect(observations.first.url).to eq('https://api.getlago.com/api/v2/taxes?limit=2')
    expect(observations.first.remaining).to eq(90)
  end

  ['', " \n"].each do |body|
    it 'returns nil for empty success bodies' do
      stub_request(:post, 'https://api.getlago.com/api/v2/payment_receipts/receipt-1/resend_email')
        .with(body: '{}').to_return(status: 200, body:)

      expect(client.payment_receipts.resend_email('receipt-1')).to be_nil
    end
  end
end
