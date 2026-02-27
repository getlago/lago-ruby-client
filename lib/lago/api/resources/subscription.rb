# frozen_string_literal: true

require 'lago/api/resources/base'

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

        def get_entitlements(external_subscription_id)
          response = connection.get(entitlements_uri(external_subscription_id), identifier: nil)
          JSON.parse(response.to_json, object_class: OpenStruct).entitlements
        end

        def update_entitlements(external_subscription_id, params)
          response = connection.patch(
            entitlements_uri(external_subscription_id),
            identifier: nil,
            body: whitelist_entitlements_update_params(params),
          )
          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def delete_entitlement(external_subscription_id, feature_code)
          response = connection.destroy(entitlements_uri(external_subscription_id, feature_code), identifier: nil)
          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def delete_entitlement_privilege(external_subscription_id, entitlement_code, privilege_code)
          response = connection.destroy(
            entitlements_uri(external_subscription_id, entitlement_code, "privileges/#{privilege_code}"),
            identifier: nil,
          )
          JSON.parse(response.to_json, object_class: OpenStruct)
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

        def create_alerts(external_subscription_id, params)
          response = connection.post(
            whitelist_alert_batch_create_params(params),
            alert_uri(external_subscription_id),
          )
          JSON.parse(response.to_json, object_class: OpenStruct).alerts
        end

        def delete_alerts(external_subscription_id)
          connection.destroy(alert_uri(external_subscription_id), identifier: nil)
        end

        # Charges
        def get_all_charges(external_id, options = {})
          response = connection.get_all(options, charges_uri(external_id))
          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def get_charge(external_id, charge_code)
          response = connection.get(charges_uri(external_id, charge_code), identifier: nil)
          JSON.parse(response.to_json, object_class: OpenStruct).charge
        end

        def update_charge(external_id, charge_code, params)
          response = connection.put(
            charges_uri(external_id, charge_code),
            identifier: nil,
            body: whitelist_subscription_charge_params(params),
          )
          JSON.parse(response.to_json, object_class: OpenStruct).charge
        end

        # Fixed Charges
        def get_all_fixed_charges(external_id, options = {})
          response = connection.get_all(options, fixed_charges_uri(external_id))
          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def get_fixed_charge(external_id, fixed_charge_code)
          response = connection.get(fixed_charges_uri(external_id, fixed_charge_code), identifier: nil)
          JSON.parse(response.to_json, object_class: OpenStruct).fixed_charge
        end

        def update_fixed_charge(external_id, fixed_charge_code, params)
          response = connection.put(
            fixed_charges_uri(external_id, fixed_charge_code),
            identifier: nil,
            body: whitelist_subscription_fixed_charge_params(params),
          )
          JSON.parse(response.to_json, object_class: OpenStruct).fixed_charge
        end

        # Charge Filters
        def get_all_charge_filters(external_id, charge_code, options = {})
          response = connection.get_all(options, charge_filters_uri(external_id, charge_code))
          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def get_charge_filter(external_id, charge_code, filter_id)
          response = connection.get(charge_filters_uri(external_id, charge_code, filter_id), identifier: nil)
          JSON.parse(response.to_json, object_class: OpenStruct).filter
        end

        def create_charge_filter(external_id, charge_code, params)
          response = connection.post(
            whitelist_subscription_charge_filter_params(params),
            charge_filters_uri(external_id, charge_code),
          )
          JSON.parse(response.to_json, object_class: OpenStruct).filter
        end

        def update_charge_filter(external_id, charge_code, filter_id, params)
          response = connection.put(
            charge_filters_uri(external_id, charge_code, filter_id),
            identifier: nil,
            body: whitelist_subscription_charge_filter_params(params),
          )
          JSON.parse(response.to_json, object_class: OpenStruct).filter
        end

        def destroy_charge_filter(external_id, charge_code, filter_id)
          response = connection.destroy(
            charge_filters_uri(external_id, charge_code, filter_id),
            identifier: nil,
          )
          JSON.parse(response.to_json, object_class: OpenStruct).filter
        end

        def whitelist_params(params)
          result = {
            external_customer_id: params[:external_customer_id],
            plan_code: params[:plan_code],
            name: params[:name],
            external_id: params[:external_id],
            billing_time: params[:billing_time],
            subscription_at: params[:subscription_at],
            ending_at: params[:ending_at],
            plan_overrides: params[:plan_overrides],
          }.compact

          payment_method_params = whitelist_payment_method_params(params[:payment_method])
          result[:payment_method] = payment_method_params if payment_method_params.present?

          { root_name => result }
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

        def whitelist_alert_batch_create_params(params)
          {
            alerts: (params[:alerts] || []).map do |alert|
              {
                alert_type: alert[:alert_type],
                name: alert[:name],
                code: alert[:code],
                billable_metric_code: alert[:billable_metric_code],
                thresholds: alert[:thresholds],
              }.compact
            end,
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

        def whitelist_entitlements_update_params(params)
          {
            entitlements: params,
          }
        end

        private

        def whitelist_payment_method_params(payment_method_param)
          payment_method_param&.slice(:payment_method_type, :payment_method_id)
        end

        def entitlements_uri(external_subscription_id, feature_code = nil, action = nil)
          url = "#{client.base_api_url}#{api_resource}/#{external_subscription_id}/entitlements"
          url += "/#{feature_code}" if feature_code
          url += "/#{action}" if action
          URI(url)
        end

        def alert_uri(external_subscription_id, code = nil)
          URI("#{client.base_api_url}#{api_resource}/#{external_subscription_id}/alerts#{code ? "/#{code}" : ''}")
        end

        def charges_uri(external_id, charge_code = nil)
          url = "#{client.base_api_url}#{api_resource}/#{external_id}/charges"
          url += "/#{charge_code}" if charge_code
          URI(url)
        end

        def fixed_charges_uri(external_id, fixed_charge_code = nil)
          url = "#{client.base_api_url}#{api_resource}/#{external_id}/fixed_charges"
          url += "/#{fixed_charge_code}" if fixed_charge_code
          URI(url)
        end

        def charge_filters_uri(external_id, charge_code, filter_id = nil)
          url = "#{client.base_api_url}#{api_resource}/#{external_id}/charges/#{charge_code}/filters"
          url += "/#{filter_id}" if filter_id
          URI(url)
        end

        def whitelist_subscription_charge_params(params)
          {
            charge: (params || {}).slice(
              :invoice_display_name,
              :min_amount_cents,
              :properties,
              :filters,
              :tax_codes,
              :applied_pricing_unit,
            ),
          }
        end

        def whitelist_subscription_fixed_charge_params(params)
          {
            fixed_charge: (params || {}).slice(
              :invoice_display_name,
              :units,
              :apply_units_immediately,
              :properties,
              :tax_codes,
            ),
          }
        end

        def whitelist_subscription_charge_filter_params(params)
          {
            filter: (params || {}).slice(
              :invoice_display_name,
              :properties,
              :values,
            ),
          }
        end
      end
    end
  end
end
