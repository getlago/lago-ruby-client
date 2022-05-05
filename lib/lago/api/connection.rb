# frozen_string_literal: true

module Lago
  module Api
    class Connection
      RESPONSE_SUCCESS_CODES = [200, 201, 202, 204].freeze

      def initialize(api_key, uri)
        @api_key = api_key
        @uri = uri
      end

      def post(body)
        response = http_client.send_request(
          'POST',
          uri.path,
          prepare_payload(body),
          headers
        )

        handle_response(response)
      end

      def delete(body)
        response = http_client.send_request(
          'DELETE',
          uri.path,
          prepare_payload(body),
          headers
        )

        handle_response(response)
      end

      private

      attr_reader :api_key, :uri

      def headers
        {
          'Authorization' => "Bearer #{api_key}",
          'Content-Type' => 'application/json'
        }
      end

      def handle_response(response)
        raise_error(response) unless RESPONSE_SUCCESS_CODES.include?(response.code.to_i)

        JSON.parse(response.body)
      end

      def http_client
        @http_client ||= Net::HTTP.new(uri.hostname, uri.port)
      end

      def prepare_payload(payload)
        return '' unless payload.respond_to?(:empty?)

        payload.empty? ? '' : payload.to_json
      end

      def raise_error(response)
        raise Lago::Api::HttpError.new(response.code, response.body, uri)
      end
    end
  end
end
