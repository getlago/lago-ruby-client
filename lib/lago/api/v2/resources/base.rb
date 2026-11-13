# frozen_string_literal: true

require 'lago/api/v2/connection'

module Lago
  module Api
    module V2
      module Resources
        class Base
          def initialize(client, **path_params)
            @client = client
            @path_params = path_params
          end

          private

          attr_reader :client, :path_params

          def request(method, path, params: nil, query: {}, **options)
            body_root = options.delete(:body_root)
            result_key = options.delete(:result_key)
            uri = request_uri(path, query, options)
            body = body_root ? { body_root => params } : params
            response = Connection.new(
              client.api_key,
              uri,
              max_retries: client.max_retries,
              retry_on_rate_limit: client.retry_on_rate_limit,
              on_rate_limit_info: client.on_rate_limit_info,
            ).request(method, body:)
            response = response.fetch(result_key) if result_key && response.is_a?(Hash)

            JSON.parse(response.to_json, object_class: OpenStruct)
          end

          def request_uri(path, query, identifiers)
            values = path_params.merge(identifiers)
            expanded_path = path.gsub(/\{([^}]+)\}/) do
              value = values.fetch(Regexp.last_match(1).to_sym)
              raise ArgumentError, 'Path identifiers must not be empty' if value.nil? || value.to_s.empty?

              CGI.escapeURIComponent(value.to_s)
            end
            uri = URI("#{client.base_api_url}#{expanded_path.delete_prefix('/')}")
            pairs = query_pairs(query)
            uri.query = URI.encode_www_form(pairs) unless pairs.empty?
            uri
          end

          def query_pairs(options, prefix = nil)
            options.flat_map do |key, value|
              name = prefix ? "#{prefix}[#{key}]" : key.to_s
              case value
              when Hash
                query_pairs(value, name)
              when Array
                name = "#{name}[]" unless name.end_with?('[]')
                value.map { |item| [name, item] }
              when nil
                []
              else
                [[name, value]]
              end
            end
          end
        end
      end
    end
  end
end
