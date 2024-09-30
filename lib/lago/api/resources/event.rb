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
          uri = URI("#{client.base_ingest_api_url}#{api_resource}")
          connection = Lago::Api::Connection.new(client.api_key, uri)

          payload = whitelist_params(params)
          response = connection.post(payload, uri)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def batch_create(params)
          uri = URI("#{client.base_api_url}#{api_resource}/batch")

          payload = whitelist_batch_params(params)
          connection.post(payload, uri)
        end

        def estimate_fees(params)
          uri = URI("#{client.base_api_url}#{api_resource}/estimate_fees")

          payload = whitelist_estimate_params(params)
          connection.post(payload, uri)
        end

        def whitelist_params(params)
          {
            root_name => {
              transaction_id: params[:transaction_id],
              code: params[:code],
              timestamp: params[:timestamp],
              external_subscription_id: params[:external_subscription_id],
              precise_total_amount_cents: params[:precise_total_amount_cents],
              properties: params[:properties],
            }.compact,
          }
        end

        def whitelist_batch_params(params)
          {
            events: params[:events],
          }
        end

        def whitelist_estimate_params(params)
          {
            root_name => {
              code: params[:code],
              external_subscription_id: params[:external_subscription_id],
              precise_total_amount_cents: params[:precise_total_amount_cents],
              properties: params[:properties],
            }.compact,
          }
        end
      end
    end
  end
end
