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

        def get_alert(external_subscription_id, code)
          response = connection.get(alert_uri(external_subscription_id, code), identifier: nil)
          JSON.parse(response.to_json, object_class: OpenStruct).alert
        end

        def update_alert(external_subscription_id, code, params)
          response = connection.put(
            alert_uri(external_subscription_id, code),
            identifier: nil,
            body: whitelist_alert_update_params(params),
          )
          JSON.parse(response.to_json, object_class: OpenStruct).alert
        end

        def delete_alert(external_subscription_id, code)
          response = connection.destroy(alert_uri(external_subscription_id, code), identifier: nil)
          JSON.parse(response.to_json, object_class: OpenStruct).alert
        end

        def get_alerts(external_subscription_id)
          response = connection.get(alert_uri(external_subscription_id), identifier: nil)
          JSON.parse(response.to_json, object_class: OpenStruct).alerts
        end

        def create_alert(external_subscription_id, params)
          response = connection.post(
            whitelist_alert_create_params(params),
            alert_uri(external_subscription_id),
          )
          JSON.parse(response.to_json, object_class: OpenStruct).alert
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

        def whitelist_alert_create_params(params)
          {
            alert: {
              alert_type: params[:alert_type],
              name: params[:name],
              code: params[:code],
              billable_metric_code: params[:billable_metric_code],
              thresholds: params[:thresholds],
            }.compact,
          }
        end

        def whitelist_alert_update_params(params)
          {
            alert: {
              name: params[:name],
              code: params[:code],
              billable_metric_code: params[:billable_metric_code],
              thresholds: params[:thresholds],
            }.compact,
          }
        end

        def whitelist_thresholds(params)
          (params || []).map do |p|
            (p || {}).slice(:code, :value, :recurring)
          end
        end

        private

        def alert_uri(external_subscription_id, code = nil)
          URI("#{client.base_api_url}#{api_resource}/#{external_subscription_id}/alerts#{code ? "/#{code}" : ''}")
        end
      end
    end
  end
end
