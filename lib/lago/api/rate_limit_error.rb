# frozen_string_literal: true

module Lago
  module Api
    class RateLimitError < HttpError
      attr_reader :limit, :remaining, :reset

      def initialize(code, body, uri, **options)
        super(code, body, uri)
        @limit = options[:limit]
        @remaining = options[:remaining]
        @reset = options[:reset]
      end

      def message
        base_message = "HTTP #{error_code} - URI: #{uri}.\nError: #{error_body}"
        return base_message unless reset

        "#{base_message}\nRate limit will reset in #{reset} seconds."
      end
    end
  end
end
