# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::RateLimitError do
  subject(:error) do
    described_class.new(
      429,
      'rate limited',
      uri,
      limit: limit,
      remaining: remaining,
      reset: reset
    )
  end

  let(:uri) { URI('https://api.example.com/v1/customers') }
  let(:limit) { 100 }
  let(:remaining) { 0 }
  let(:reset) { 60 }

  it 'is a subclass of HttpError' do
    expect(error).to be_a(Lago::Api::HttpError)
  end

  it 'stores rate limit attributes' do
    expect(error.limit).to eq 100
    expect(error.remaining).to eq 0
    expect(error.reset).to eq 60
  end

  describe '#message' do
    it 'includes rate limit reset time' do
      expect(error.message).to include('Rate limit will reset in 60 seconds')
    end

    context 'when reset is nil' do
      subject(:error) do
        described_class.new(429, 'rate limited', uri, limit: 100)
      end

      it 'returns base http error message' do
        expect(error.message).to match(/HTTP 429/)
        expect(error.message).not_to include('Rate limit will reset')
      end
    end
  end

  describe '#error_code' do
    it 'returns 429' do
      expect(error.error_code).to eq 429
    end
  end

  describe '#error_body' do
    it 'returns the error body' do
      expect(error.error_body).to eq 'rate limited'
    end
  end

  describe '#uri' do
    it 'returns the uri' do
      expect(error.uri).to eq uri
    end
  end
end
