# frozen_string_literal: true

module Lago
  module Api
    class RateLimitError < HttpError
      attr_reader :limit, :remaining, :reset

      def initialize(code, body, uri, limit: nil, remaining: nil, reset: nil)
        super(code, body, uri)
        @limit = limit
        @remaining = remaining
        @reset = reset
      end

      def message
        base_message = "HTTP #{error_code} - URI: #{uri}.\nError: #{error_body}"
        return base_message unless reset

        "#{base_message}\nRate limit will reset in #{reset} seconds."
      end
    end
  end
end
