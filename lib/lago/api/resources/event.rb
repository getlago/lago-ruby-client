# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Event < Base
        def api_resource
          'events'
        end

        def root_name
          'event'
        end

        def create(params)
          payload = whitelist_params(params)
          connection.post(payload)
        end

        def batch_create(params)
          uri = URI("#{client.base_api_url}#{api_resource}/batch")

          payload = whitelist_batch_params(params)
          connection.post(payload, uri)
        end

        def whitelist_params(params)
          {
            root_name => {
              transaction_id: params[:transaction_id],
              external_customer_id: params[:external_customer_id],
              code: params[:code],
              timestamp: params[:timestamp],
              external_subscription_id: params[:external_subscription_id],
              properties: params[:properties]
            }.compact
          }
        end

        def whitelist_batch_params(params)
          {
            root_name => {
              transaction_id: params[:transaction_id],
              external_customer_id: params[:external_customer_id],
              code: params[:code],
              timestamp: params[:timestamp],
              external_subscription_ids: params[:external_subscription_ids],
              properties: params[:properties]
            }.compact
          }
        end
      end
    end
  end
end
