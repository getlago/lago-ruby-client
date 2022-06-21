# frozen_string_literal: true

module Lago
  module Api
    class Connection
      RESPONSE_SUCCESS_CODES = [200, 201, 202, 204].freeze

      def initialize(api_key, uri)
        @api_key = api_key
        @uri = uri
      end

      def post(body, path = uri.path)
        response = http_client.send_request(
          'POST',
          path,
          prepare_payload(body),
          headers
        )

        handle_response(response)
      end

      def put(path = uri.path, lago_id:, body:)
        uri_path = "#{path}/#{lago_id}"
        response = http_client.send_request(
          'PUT',
          uri_path,
          prepare_payload(body),
          headers
        )

        handle_response(response)
      end

      def delete(body, path = uri.path)
        response = http_client.send_request(
          'DELETE',
          path,
          prepare_payload(body),
          headers
        )

        handle_response(response)
      end

      def get(path)
        response = http_client.send_request(
          'GET',
          path,
          prepare_payload(nil),
          headers
        )

        handle_response(response)
      end

      private

      attr_reader :api_key, :uri

      def headers
        {
          'Authorization' => "Bearer #{api_key}",
          'Content-Type' => 'application/json',
          'User-Agent' => "Lago Ruby v#{Lago::VERSION}"
        }
      end

      def handle_response(response)
        raise_error(response) unless RESPONSE_SUCCESS_CODES.include?(response.code.to_i)

        response.body.empty? ? true : JSON.parse(response.body)
      end

      def http_client
        http_client = Net::HTTP.new(uri.hostname, uri.port)
        http_client.use_ssl = true

        http_client
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
