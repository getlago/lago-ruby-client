# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Connection do
  subject(:connection) do
    described_class.new(
      'fake-api-key',
      uri
    )
  end

  let(:uri) { URI('https://testapi.example.org') }

  context 'when an unsuccessful request is made' do
    before do
      stub_request(:post, 'https://testapi.example.org/NOTFOUND')
        .to_return(status: 404, body: "")
    end

    it 'raises an exception with an integer error code' do
      expect { connection.post({}, '/NOTFOUND') }.to raise_error { |exception|
        expect(exception).to be_a(Lago::Api::HttpError)
        expect(exception.error_code).to eq 404
      }
    end
  end

  describe '#get' do
    let(:identifier) { 'gid://app/Customer/12 34' }

    it 'encodes the identifier' do
      stub_request(:get, 'https://testapi.example.org:443/gid:%2F%2Fapp%2FCustomer%2F12%2034')

      connection.get(uri.path, identifier: identifier)
    end
  end

  describe '#put' do
    let(:identifier) { 'gid://app/Customer/12 34' }

    it 'encodes the identifier' do
      stub_request(:put, 'https://testapi.example.org:443/gid:%2F%2Fapp%2FCustomer%2F12%2034')

      connection.put(uri.path, identifier: identifier, body: nil)
    end
  end

  describe '#patch' do
    let(:identifier) { 'gid://app/Customer/12 34' }

    it 'encodes the identifier' do
      stub_request(:patch, 'https://testapi.example.org:443/gid:%2F%2Fapp%2FCustomer%2F12%2034')

      connection.patch(uri.path, identifier: identifier, body: nil)
    end
  end

  describe '#destroy' do
    let(:identifier) { 'gid://app/Customer/12 34' }

    it 'encodes the identifier' do
      stub_request(:delete, 'https://testapi.example.org:443/gid:%2F%2Fapp%2FCustomer%2F12%2034')

      connection.destroy(uri.path, identifier: identifier)
    end
  end

  context 'when rate limit (429) is received' do
    it 'raises RateLimitError with rate limit headers' do
      stub_request(:post, 'https://testapi.example.org/test')
        .to_return(
          status: 429,
          body: '{"error": "rate limited"}',
          headers: {
            'x-ratelimit-limit' => '100',
            'x-ratelimit-remaining' => '0',
            'x-ratelimit-reset' => '60'
          }
        )

      expect { connection.post({}, '/test') }.to raise_error { |exception|
        expect(exception).to be_a(Lago::Api::RateLimitError)
        expect(exception.error_code).to eq 429
        expect(exception.limit).to eq 100
        expect(exception.remaining).to eq 0
        expect(exception.reset).to eq 60
      }
    end

    context 'when retry_on_rate_limit is enabled' do
      subject(:connection) do
        described_class.new(
          'fake-api-key',
          uri,
          max_retries: 1,
          retry_on_rate_limit: true
        )
      end

      it 'retries the request after sleeping for reset seconds' do
        call_count = 0

        stub_request(:post, 'https://testapi.example.org/test')
          .to_return do
            call_count += 1
            if call_count == 1
              {
                status: 429,
                body: '{"error": "rate limited"}',
                headers: {
                  'x-ratelimit-reset' => '1'
                }
              }
            else
              {
                status: 200,
                body: '{"result": "success"}'
              }
            end
          end

        allow(connection).to receive(:sleep)

        result = connection.post({}, '/test')

        expect(result).to eq('result' => 'success')
        expect(connection).to have_received(:sleep).with(1)
      end

      it 'uses exponential backoff when reset header is missing' do
        call_count = 0

        stub_request(:post, 'https://testapi.example.org/test')
          .to_return do
            call_count += 1
            if call_count == 1
              {
                status: 429,
                body: '{"error": "rate limited"}'
              }
            else
              {
                status: 200,
                body: '{"result": "success"}'
              }
            end
          end

        allow(connection).to receive(:sleep)

        result = connection.post({}, '/test')

        expect(result).to eq('result' => 'success')
        expect(connection).to have_received(:sleep).with(1)
      end

      it 'raises error after max retries exceeded' do
        stub_request(:post, 'https://testapi.example.org/test')
          .to_return(
            status: 429,
            body: '{"error": "rate limited"}',
            headers: { 'x-ratelimit-reset' => '1' }
          )

        allow(connection).to receive(:sleep)

        expect { connection.post({}, '/test') }.to raise_error(Lago::Api::RateLimitError)
      end
    end

    context 'when retry_on_rate_limit is disabled' do
      subject(:connection) do
        described_class.new(
          'fake-api-key',
          uri,
          retry_on_rate_limit: false
        )
      end

      it 'raises RateLimitError immediately without retrying' do
        stub_request(:post, 'https://testapi.example.org/test')
          .to_return(
            status: 429,
            body: '{"error": "rate limited"}',
            headers: { 'x-ratelimit-reset' => '60' }
          )

        expect { connection.post({}, '/test') }.to raise_error(Lago::Api::RateLimitError)
      end
    end
  end
end
