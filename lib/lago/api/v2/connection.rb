# frozen_string_literal: true

require 'lago/api/connection'
require 'lago/api/v2/http_error'
require 'lago/api/v2/rate_limit_error'

module Lago
  module Api
    module V2
      class Connection < Lago::Api::Connection
        def request(method, body: nil)
          execute_request(method:) do
            http_client.send_request(method, uri.request_uri, body&.to_json, headers)
          end
        end

        private

        def parse_response_body(response)
          return nil if response.body.nil? || response.body.strip.empty?

          JSON.parse(response.body)
        end

        def raise_error(response)
          status = response.code.to_i
          raise HttpError.new(status, response.body, uri) unless status == 429

          limit, remaining, reset = parse_rate_limit_headers(response)
          raise RateLimitError.new(status, response.body, uri, limit:, remaining:, reset:)
        end
      end
    end
  end
end
