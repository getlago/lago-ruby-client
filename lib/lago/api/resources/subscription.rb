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

        def create_with_override(params)
          uri = URI("#{client.base_api_url}#{api_resource}/override")

          payload = whitelist_override_params(params)
          response = connection.post(payload, uri)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def whitelist_params(params)
          {
            root_name => {
              external_customer_id: params[:external_customer_id],
              plan_code: params[:plan_code],
              name: params[:name],
              external_id: params[:external_id],
              billing_time: params[:billing_time]
            }.compact
          }
        end

        def whitelist_override_params(params)
          {
            root_name => {
              external_customer_id: params[:external_customer_id],
              name: params[:name],
              external_id: params[:external_id],
              billing_time: params[:billing_time],
              plan: whitelist_plan(params[:plan])
            }.compact
          }
        end

        def whitelist_plan(plan)
          result_hash = {
            amount_cents: plan[:amount_cents],
            amount_currency: plan[:amount_currency],
            trial_period: plan[:trial_period]
          }

          whitelist_charges(plan[:charges]).tap do |charges|
            result_hash[:charges] = charges unless charges.empty?
          end

          result_hash
        end

        def whitelist_charges(charges)
          processed_charges = []

          charges.each do |c|
            result = (c || {}).slice(:id, :charge_model, :properties)

            processed_charges << result unless result.empty?
          end

          processed_charges
        end
      end
    end
  end
end
