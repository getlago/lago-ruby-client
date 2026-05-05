# frozen_string_literal: true

module Lago
  module Api
    # Parsed rate limit headers from a Lago API response.
    #
    # Delivered to the +on_rate_limit_info+ callback after every successful
    # request so callers can build observability around the rate limit
    # (warn at thresholds, emit metrics, etc.).
    class RateLimitInfo
      attr_reader :limit, :remaining, :reset, :method, :url

      # Parses x-ratelimit-* headers from a Net::HTTPResponse-like object.
      # Returns +nil+ when no rate limit headers are present.
      def self.parse(response, method:, url:)
        limit = response['x-ratelimit-limit']
        remaining = response['x-ratelimit-remaining']
        reset = response['x-ratelimit-reset']

        return nil if limit.nil? && remaining.nil? && reset.nil?

        new(
          limit: limit&.to_i,
          remaining: remaining&.to_i,
          reset: reset&.to_i,
          method:,
          url:,
        )
      end

      def initialize(limit:, remaining:, reset:, method:, url:)
        @limit = limit
        @remaining = remaining
        @reset = reset
        @method = method
        @url = url
      end

      # Returns the fraction of the rate limit currently used as a Float in
      # [0.0, 1.0], or +nil+ when the headers aren't usable (missing limit,
      # zero limit, missing remaining).
      def usage_pct
        return nil if limit.nil? || remaining.nil? || limit.to_i <= 0

        1.0 - (remaining.to_f / limit)
      end
    end
  end
end
