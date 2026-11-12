# frozen_string_literal: true

require 'cgi'
require 'lago/api/resources/base'
require 'lago/api/resources/webhook_endpoint'

module Lago
  module Api
    module Resources
      module V2
        class WebhookEndpoint < Base
          def api_resource
            'webhook_endpoints'
          end

          def root_name
            'webhook_endpoint'
          end

          def whitelist_params(params)
            Resources::WebhookEndpoint.new(client).whitelist_params(params)
          end

          def create(params, expands: [])
            response = connection.post(whitelist_params(params), build_path(nil, expands))[root_name]

            JSON.parse(response.to_json, object_class: OpenStruct)
          end

          def update(lago_id, params, expands: [])
            response = connection.put(
              build_path(lago_id, expands),
              identifier: nil,
              body: whitelist_params(params),
            )[root_name]

            JSON.parse(response.to_json, object_class: OpenStruct)
          end

          def get(lago_id, expands: [])
            response = connection.get(build_path(lago_id, expands), identifier: nil)[root_name]

            JSON.parse(response.to_json, object_class: OpenStruct)
          end

          def destroy(*)
            raise NotImplementedError
          end

          def get_all(*)
            raise NotImplementedError
          end

          private

          # The v2 URL sits next to the v1 base (`<api_url>api/v1/`), so any api_url path prefix is kept.
          def uri
            URI.join(client.base_api_url, '../v2/webhook_endpoints')
          end

          def connection
            Lago::Api::Connection.new(
              client.api_key,
              uri,
              max_retries: client.max_retries,
              retry_on_rate_limit: client.retry_on_rate_limit,
              on_rate_limit_info: client.on_rate_limit_info,
            )
          end

          def build_path(lago_id, expands)
            path = uri.path
            path += "/#{CGI.escapeURIComponent(lago_id)}" unless lago_id.nil?

            query = Array(expands).map { |expand| ['expands[]', expand] }
            if query.empty?
              path
            else
              "#{path}?#{URI.encode_www_form(query)}"
            end
          end
        end
      end
    end
  end
end
