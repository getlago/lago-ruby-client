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

      def put(path = uri.path, identifier:, body:)
        uri_path = identifier.nil? ? path : "#{path}/#{identifier}"
        response = http_client.send_request(
          'PUT',
          uri_path,
          prepare_payload(body),
          headers
        )

        handle_response(response)
      end

      def get(path = uri.path, identifier:)
        uri_path = identifier.nil? ? path : "#{path}/#{URI.encode_www_form_component(identifier)}"
        response = http_client.send_request(
          'GET',
          uri_path,
          prepare_payload(nil),
          headers
        )

        handle_response(response)
      end

      def destroy(path = uri.path, identifier:, options: nil)
        uri_path = path
        uri_path += "/#{identifier}" if identifier
        uri_path += "?#{URI.encode_www_form(options)}" unless options.nil?
        response = http_client.send_request(
          'DELETE',
          uri_path,
          prepare_payload(nil),
          headers
        )

        handle_response(response)
      end

      def get_all(options, path = uri.path)
        uri_path = options.empty? ? path : "#{path}?#{URI.encode_www_form(options)}"

        response = http_client.send_request(
          'GET',
          uri_path,
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
      rescue JSON::ParserError
        response.body
      end

      def http_client
        http_client = Net::HTTP.new(uri.hostname, uri.port)
        http_client.use_ssl = true if uri.scheme == 'https'

        http_client
      end

      def prepare_payload(payload)
        return '' unless payload.respond_to?(:empty?)

        payload.empty? ? '' : payload.to_json
      end

      def raise_error(response)
        raise Lago::Api::HttpError.new(response.code.to_i, response.body, uri)
      end
    end
  end
end
