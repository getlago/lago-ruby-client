# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::RateLimitInfo do
  describe '#usage_pct' do
    it 'returns the fraction of the limit used' do
      info = described_class.new(limit: 100, remaining: 20, reset: 5, method: 'GET', url: 'https://x')
      expect(info.usage_pct).to eq(0.80)
    end

    it 'returns 1.0 at saturation' do
      info = described_class.new(limit: 100, remaining: 0, reset: 5, method: 'GET', url: 'https://x')
      expect(info.usage_pct).to eq(1.0)
    end

    it 'returns nil when limit is missing' do
      info = described_class.new(limit: nil, remaining: 20, reset: 5, method: 'GET', url: 'https://x')
      expect(info.usage_pct).to be_nil
    end

    it 'returns nil when remaining is missing' do
      info = described_class.new(limit: 100, remaining: nil, reset: 5, method: 'GET', url: 'https://x')
      expect(info.usage_pct).to be_nil
    end

    it 'returns nil when limit is zero' do
      info = described_class.new(limit: 0, remaining: 0, reset: 5, method: 'GET', url: 'https://x')
      expect(info.usage_pct).to be_nil
    end
  end

  describe '.parse' do
    # Net::HTTPResponse mixes #[] in via Net::HTTPHeader, which RSpec's
    # instance_double cannot see, so we use a plain stub that exposes #[].
    let(:response) do
      headers = {
        'x-ratelimit-limit' => limit_header,
        'x-ratelimit-remaining' => remaining_header,
        'x-ratelimit-reset' => reset_header,
      }
      Class.new do
        def initialize(headers)
          @headers = headers
        end

        def [](key)
          @headers[key]
        end
      end.new(headers)
    end

    context 'when all headers are present' do
      let(:limit_header) { '100' }
      let(:remaining_header) { '42' }
      let(:reset_header) { '5' }

      it 'returns a populated RateLimitInfo' do
        info = described_class.parse(response, method: 'GET', url: 'https://x')
        expect(info.limit).to eq(100)
        expect(info.remaining).to eq(42)
        expect(info.reset).to eq(5)
        expect(info.method).to eq('GET')
        expect(info.url).to eq('https://x')
      end
    end

    context 'when no headers are present' do
      let(:limit_header) { nil }
      let(:remaining_header) { nil }
      let(:reset_header) { nil }

      it 'returns nil' do
        expect(described_class.parse(response, method: 'GET', url: 'https://x')).to be_nil
      end
    end

    context 'when only some headers are present' do
      let(:limit_header) { '100' }
      let(:remaining_header) { nil }
      let(:reset_header) { nil }

      it 'returns a partially populated RateLimitInfo' do
        info = described_class.parse(response, method: 'GET', url: 'https://x')
        expect(info.limit).to eq(100)
        expect(info.remaining).to be_nil
        expect(info.reset).to be_nil
      end
    end
  end
end
