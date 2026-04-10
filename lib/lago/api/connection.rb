# frozen_string_literal: true

require 'cgi'

module Lago
  module Api
    class Connection
      RESPONSE_SUCCESS_CODES = [200, 201, 202, 204].freeze
      DEFAULT_MAX_RETRIES = 3
      INITIAL_BACKOFF = 1
      BACKOFF_MULTIPLIER = 2

      def initialize(api_key, uri, max_retries: DEFAULT_MAX_RETRIES, retry_on_rate_limit: true)
        @api_key = api_key
        @uri = uri
        @max_retries = max_retries
        @retry_on_rate_limit = retry_on_rate_limit
      end

      def post(body, path = uri.path)
        execute_request do
          http_client.send_request(
            'POST',
            path,
            prepare_payload(body),
            headers
          )
        end
      end

      def put(path = uri.path, identifier:, body:)
        uri_path = identifier.nil? ? path : "#{path}/#{CGI.escapeURIComponent(identifier)}"
        execute_request do
          http_client.send_request(
            'PUT',
            uri_path,
            prepare_payload(body),
            headers
          )
        end
      end

      def patch(path = uri.path, identifier:, body:)
        uri_path = identifier.nil? ? path : "#{path}/#{CGI.escapeURIComponent(identifier)}"
        execute_request do
          http_client.send_request(
            'PATCH',
            uri_path,
            prepare_payload(body),
            headers
          )
        end
      end

      def get(path = uri.path, identifier:)
        uri_path = identifier.nil? ? path : "#{path}/#{CGI.escapeURIComponent(identifier)}"
        execute_request do
          http_client.send_request(
            'GET',
            uri_path,
            prepare_payload(nil),
            headers
          )
        end
      end

      def destroy(path = uri.path, identifier:, options: nil)
        uri_path = path
        uri_path += "/#{CGI.escapeURIComponent(identifier)}" if identifier
        uri_path += "?#{URI.encode_www_form(options)}" unless options.nil?
        execute_request do
          http_client.send_request(
            'DELETE',
            uri_path,
            prepare_payload(nil),
            headers
          )
        end
      end

      def get_all(options, path = uri.path)
        uri_path = options.empty? ? path : "#{path}?#{URI.encode_www_form(options)}"

        execute_request do
          http_client.send_request(
            'GET',
            uri_path,
            prepare_payload(nil),
            headers
          )
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

      def execute_request(retry_count = 0, &block)
        response = block.call
        handle_response(response, retry_count, block)
      end

      def handle_response(response, retry_count, block)
        code = response.code.to_i

        if code == 429 && @retry_on_rate_limit && retry_count < @max_retries
          handle_rate_limit(response, retry_count, block)
        elsif !RESPONSE_SUCCESS_CODES.include?(code)
          raise_error(response)
        else
          parse_response_body(response)
        end
      rescue JSON::ParserError
        response.body
      end

      def handle_rate_limit(response, retry_count, block)
        reset_seconds = extract_reset_seconds(response, retry_count)
        sleep(reset_seconds)
        execute_request(retry_count + 1, &block)
      end

      def parse_response_body(response)
        response.body.empty? || JSON.parse(response.body)
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
        code = response.code.to_i

        if code == 429
          limit, remaining, reset = parse_rate_limit_headers(response)
          raise Lago::Api::RateLimitError.new(code, response.body, uri, limit: limit, remaining: remaining, reset: reset)
        else
          raise Lago::Api::HttpError.new(code, response.body, uri)
        end
      end

      def parse_rate_limit_headers(response)
        limit = response['x-ratelimit-limit']&.to_i
        remaining = response['x-ratelimit-remaining']&.to_i
        reset = response['x-ratelimit-reset']&.to_i

        [limit, remaining, reset]
      end

      def extract_reset_seconds(response, retry_count)
        reset_header = response['x-ratelimit-reset']&.to_i
        return [reset_header, INITIAL_BACKOFF].max if reset_header

        # Exponential backoff if header is missing
        calculate_backoff(retry_count)
      end

      def calculate_backoff(retry_count)
        INITIAL_BACKOFF * (BACKOFF_MULTIPLIER ** retry_count)
      end
    end
  end
end
