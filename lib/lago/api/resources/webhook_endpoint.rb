# frozen_string_literal: true

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
          {
            root_name => {
              webhook_url: params[:webhook_url],
            }.compact,
          }
        end
      end
    end
  end
end
