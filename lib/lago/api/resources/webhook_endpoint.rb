# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      class WebhookEndpoint < Base
        def api_resource
          'webhook_endpoints'
        end

        def root_name
          'webhook_endpoint'
        end

        def whitelist_params(params)
          result_hash = {}
          result_hash[:webhook_url] = params[:webhook_url] if params.key?(:webhook_url)
          result_hash[:signature_algo] = params[:signature_algo] if params.key?(:signature_algo)
          result_hash[:event_types] = params[:event_types] if params.key?(:event_types)
          result_hash[:name] = params[:name] if params.key?(:name)

          { root_name => result_hash }
        end
      end
    end
  end
end
