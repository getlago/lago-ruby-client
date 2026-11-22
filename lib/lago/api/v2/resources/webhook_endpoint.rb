# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class WebhookEndpoint < Base
          # GET /webhook_endpoints
          def get_all(options = {})
            request('GET', '/webhook_endpoints', query: options)
          end

          # POST /webhook_endpoints
          def create(params)
            request(
              'POST',
              '/webhook_endpoints',
              params:,
              body_root: 'webhook_endpoint',
              result_key: 'webhook_endpoint',
            )
          end

          # GET /webhook_endpoints/{lago_id}
          def get(lago_id, options = {})
            request('GET', '/webhook_endpoints/{lago_id}', result_key: 'webhook_endpoint', query: options, lago_id:)
          end

          # PUT /webhook_endpoints/{lago_id}
          def update(params, lago_id)
            request(
              'PUT',
              '/webhook_endpoints/{lago_id}',
              params:,
              body_root: 'webhook_endpoint',
              result_key: 'webhook_endpoint',
              lago_id:,
            )
          end

          # PATCH /webhook_endpoints/{lago_id}
          def patch(params, lago_id)
            request(
              'PATCH',
              '/webhook_endpoints/{lago_id}',
              params:,
              body_root: 'webhook_endpoint',
              result_key: 'webhook_endpoint',
              lago_id:,
            )
          end

          # DELETE /webhook_endpoints/{lago_id}
          def destroy(lago_id)
            request('DELETE', '/webhook_endpoints/{lago_id}', result_key: 'webhook_endpoint', lago_id:)
          end
        end
      end
    end
  end
end
