# frozen_string_literal: true

require 'cgi'

module Lago
  module Api
    class Connection
      RESPONSE_SUCCESS_CODES = [200, 201, 202, 204].freeze
      RETRY_LIMIT_ERROR_CODE = 429
      MAX_RETRIES = 3
      RETRY_WAIT_TIME_IN_SECONDS = 1 # FIXME: Add the correct value for the wait time between retries

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
        uri_path = identifier.nil? ? path : "#{path}/#{CGI.escapeURIComponent(identifier)}"

        with_retry_limit do
          response = http_client.send_request(
            'PUT',
            uri_path,
            prepare_payload(body),
            headers
          )

          handle_response(response)
        end
      end

      def patch(path = uri.path, identifier:, body:)
        uri_path = identifier.nil? ? path : "#{path}/#{CGI.escapeURIComponent(identifier)}"

        with_retry_limit do
          response = http_client.send_request(
            'PATCH',
            uri_path,
            prepare_payload(body),
            headers
          )

          handle_response(response)
        end
      end

      def get(path = uri.path, identifier:)
        uri_path = identifier.nil? ? path : "#{path}/#{CGI.escapeURIComponent(identifier)}"

        with_retry_limit do
          response = http_client.send_request(
            'GET',
            uri_path,
            prepare_payload(nil),
            headers
          )

          handle_response(response)
        end
      end

      def destroy(path = uri.path, identifier:, options: nil)
        uri_path = path
        uri_path += "/#{CGI.escapeURIComponent(identifier)}" if identifier
        uri_path += "?#{URI.encode_www_form(options)}" unless options.nil?

        with_retry_limit do
          response = http_client.send_request(
            'DELETE',
            uri_path,
            prepare_payload(nil),
            headers
          )

          handle_response(response)
        end
      end

      def get_all(options, path = uri.path)
        uri_path = options.empty? ? path : "#{path}?#{URI.encode_www_form(options)}"

        with_retry_limit do
          response = http_client.send_request(
            'GET',
            uri_path,
            prepare_payload(nil),
            headers
          )

          handle_response(response)
        end
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
        raise_retry_limit_error(response) if response.code.to_i == RETRY_LIMIT_ERROR_CODE
        raise_error(response) unless RESPONSE_SUCCESS_CODES.include?(response.code.to_i)

        response.body.empty? || JSON.parse(response.body)
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

      def raise_retry_limit_error(response)
        raise Lago::Api::RetryLimitError.new(response.code.to_i, response.body, uri)
      end

      def with_retry_limit
        attempts = 0

        begin
          attempts += 1

          yield
        rescue Lago::Api::RetryLimitError => e
          if attempts < MAX_RETRIES
            sleep(RETRY_WAIT_TIME_IN_SECONDS)
            retry
          end

          raise e
        end
      end
    end
  end
end
