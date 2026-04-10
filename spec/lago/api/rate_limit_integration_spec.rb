# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Rate Limit Integration' do
  let(:client) do
    Lago::Api::Client.new(
      api_key: 'test-key',
      max_retries: 2,
      retry_on_rate_limit: true
    )
  end

  describe 'Client initialization with rate limit options' do
    it 'accepts max_retries parameter' do
      client = Lago::Api::Client.new(api_key: 'test', max_retries: 5)
      expect(client.max_retries).to eq 5
    end

    it 'accepts retry_on_rate_limit parameter' do
      client = Lago::Api::Client.new(api_key: 'test', retry_on_rate_limit: false)
      expect(client.retry_on_rate_limit).to be false
    end

    it 'defaults to max_retries of 3' do
      client = Lago::Api::Client.new(api_key: 'test')
      expect(client.max_retries).to eq 3
    end

    it 'defaults to retry_on_rate_limit true' do
      client = Lago::Api::Client.new(api_key: 'test')
      expect(client.retry_on_rate_limit).to be true
    end
  end

  describe 'Connection with rate limit retry' do
    let(:uri) { URI('https://api.example.com/v1') }

    context 'when 429 response includes reset header' do
      it 'sleeps for the exact duration specified in header' do
        connection = Lago::Api::Connection.new(
          'test-key',
          uri,
          max_retries: 1,
          retry_on_rate_limit: true
        )

        call_count = 0
        stub_request(:post, 'https://api.example.com/v1/test')
          .to_return do
            call_count += 1
            if call_count == 1
              {
                status: 429,
                body: '{}',
                headers: {
                  'x-ratelimit-limit' => '100',
                  'x-ratelimit-remaining' => '0',
                  'x-ratelimit-reset' => '5'
                }
              }
            else
              { status: 200, body: '{"result": "ok"}' }
            end
          end

        allow(connection).to receive(:sleep)
        result = connection.post({}, '/v1/test')

        expect(result).to eq('result' => 'ok')
        expect(connection).to have_received(:sleep).with(5)
      end
    end

    context 'when 429 response is missing reset header' do
      it 'uses exponential backoff' do
        connection = Lago::Api::Connection.new(
          'test-key',
          uri,
          max_retries: 2,
          retry_on_rate_limit: true
        )

        call_count = 0
        stub_request(:post, 'https://api.example.com/v1/test')
          .to_return do
            call_count += 1
            if call_count < 3
              { status: 429, body: '{}' }
            else
              { status: 200, body: '{"result": "ok"}' }
            end
          end

        allow(connection).to receive(:sleep)
        result = connection.post({}, '/v1/test')

        expect(result).to eq('result' => 'ok')
        expect(connection).to have_received(:sleep).twice
      end
    end

    context 'when max_retries is 0' do
      it 'raises immediately without retrying' do
        connection = Lago::Api::Connection.new(
          'test-key',
          uri,
          max_retries: 0,
          retry_on_rate_limit: true
        )

        stub_request(:post, 'https://api.example.com/v1/test')
          .to_return(
            status: 429,
            body: '{"error": "rate limited"}',
            headers: { 'x-ratelimit-reset' => '60' }
          )

        expect { connection.post({}, '/v1/test') }.to raise_error(Lago::Api::RateLimitError)
      end
    end

    context 'when retry_on_rate_limit is false' do
      it 'does not retry and raises immediately' do
        connection = Lago::Api::Connection.new(
          'test-key',
          uri,
          max_retries: 10,
          retry_on_rate_limit: false
        )

        stub_request(:post, 'https://api.example.com/v1/test')
          .to_return(
            status: 429,
            body: '{"error": "rate limited"}',
            headers: {
              'x-ratelimit-limit' => '100',
              'x-ratelimit-remaining' => '0',
              'x-ratelimit-reset' => '60'
            }
          )

        allow(connection).to receive(:sleep)

        expect { connection.post({}, '/v1/test') }.to raise_error(Lago::Api::RateLimitError) do |error|
          expect(error.limit).to eq 100
          expect(error.remaining).to eq 0
          expect(error.reset).to eq 60
        end
        expect(connection).not_to have_received(:sleep)
      end
    end

    context 'when multiple HTTP methods are called' do
      it 'retries GET requests' do
        connection = Lago::Api::Connection.new(
          'test-key',
          uri,
          max_retries: 1,
          retry_on_rate_limit: true
        )

        call_count = 0
        stub_request(:get, 'https://api.example.com/v1/resource')
          .to_return do
            call_count += 1
            if call_count == 1
              { status: 429, body: '{}', headers: { 'x-ratelimit-reset' => '1' } }
            else
              { status: 200, body: '{"data": "value"}' }
            end
          end

        allow(connection).to receive(:sleep)
        result = connection.get('/v1/resource', identifier: nil)

        expect(result).to eq('data' => 'value')
        expect(connection).to have_received(:sleep).with(1)
      end

      it 'retries PUT requests' do
        connection = Lago::Api::Connection.new(
          'test-key',
          uri,
          max_retries: 1,
          retry_on_rate_limit: true
        )

        call_count = 0
        stub_request(:put, 'https://api.example.com/v1/resource/123')
          .to_return do
            call_count += 1
            if call_count == 1
              { status: 429, body: '{}', headers: { 'x-ratelimit-reset' => '1' } }
            else
              { status: 200, body: '{"updated": true}' }
            end
          end

        allow(connection).to receive(:sleep)
        result = connection.put('/v1/resource', identifier: '123', body: {})

        expect(result).to eq('updated' => true)
        expect(connection).to have_received(:sleep).with(1)
      end
    end
  end

  describe 'RateLimitError information' do
    let(:error) do
      Lago::Api::RateLimitError.new(
        429,
        'Too Many Requests',
        URI('https://api.example.com/v1/customers'),
        limit: 100,
        remaining: 0,
        reset: 45
      )
    end

    it 'provides all rate limit information' do
      expect(error.error_code).to eq 429
      expect(error.limit).to eq 100
      expect(error.remaining).to eq 0
      expect(error.reset).to eq 45
      expect(error.message).to include('Rate limit will reset in 45 seconds')
    end
  end
end
