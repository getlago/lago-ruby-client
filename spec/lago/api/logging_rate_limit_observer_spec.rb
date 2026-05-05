# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::LoggingRateLimitObserver do
  let(:io) { StringIO.new }
  let(:logger) { Logger.new(io) }

  it 'logs when usage crosses a threshold' do
    observer = described_class.new(thresholds: [0.80, 0.90, 0.95], logger:)
    observer.call(
      Lago::Api::RateLimitInfo.new(limit: 100, remaining: 4, reset: 10, method: 'GET', url: 'https://x'),
    )

    expect(io.string).to include('96%')
  end

  it 'is silent below the lowest threshold' do
    observer = described_class.new(thresholds: [0.80], logger:)
    observer.call(
      Lago::Api::RateLimitInfo.new(limit: 100, remaining: 50, reset: 10, method: 'GET', url: 'https://x'),
    )

    expect(io.string).to be_empty
  end

  it 'is silent when usage_pct is nil' do
    observer = described_class.new(logger:)
    observer.call(
      Lago::Api::RateLimitInfo.new(limit: nil, remaining: nil, reset: nil, method: 'GET', url: 'https://x'),
    )

    expect(io.string).to be_empty
  end
end
