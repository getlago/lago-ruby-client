# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Subscription < Base
        def api_resource
          'subscriptions'
        end

        def root_name
          'subscription'
        end

        def lifetime_usage(external_subscription_id)
          uri = URI(
            "#{client.base_api_url}#{api_resource}/#{external_subscription_id}/lifetime_usage",
          )
          response = connection.get(uri, identifier: nil)
          JSON.parse(response.to_json, object_class: OpenStruct).lifetime_usage
        end

        def update_lifetime_usage(external_subscription_id, params)
          uri = URI(
            "#{client.base_api_url}#{api_resource}/#{external_subscription_id}/lifetime_usage",
          )

          response = connection.put(
            uri,
            identifier: nil,
            body: whitelist_lifetime_usage_params(params),
          )
          JSON.parse(response.to_json, object_class: OpenStruct).lifetime_usage
        end

        def whitelist_params(params)
          {
            root_name => {
              external_customer_id: params[:external_customer_id],
              plan_code: params[:plan_code],
              name: params[:name],
              external_id: params[:external_id],
              billing_time: params[:billing_time],
              subscription_at: params[:subscription_at],
              ending_at: params[:ending_at],
              plan_overrides: params[:plan_overrides],
            }.compact,
          }
        end

        def whitelist_lifetime_usage_params(params)
          {
            lifetime_usage: {
              external_historical_usage_amount_cents: params[:external_historical_usage_amount_cents],
            },
          }
        end
      end
    end
  end
end
