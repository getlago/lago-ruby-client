# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      class Plan < Base
        def api_resource
          'plans'
        end

        def root_name
          'plan'
        end

        def get_entitlements(plan_code)
          response = connection.get(entitlements_uri(plan_code), identifier: nil)
          JSON.parse(response.to_json, object_class: OpenStruct).entitlements
        end

        def create_entitlements(plan_code, params)
          response = connection.post(
            whitelist_entitlements_params(params),
            entitlements_uri(plan_code),
          )
          JSON.parse(response.to_json, object_class: OpenStruct).entitlements
        end

        def update_entitlements(plan_code, params)
          response = connection.patch(
            entitlements_uri(plan_code),
            identifier: nil,
            body: whitelist_entitlements_params(params),
          )
          JSON.parse(response.to_json, object_class: OpenStruct).entitlements
        end

        def get_entitlement(plan_code, feature_code)
          response = connection.get(entitlements_uri(plan_code, feature_code), identifier: nil)
          JSON.parse(response.to_json, object_class: OpenStruct).entitlement
        end

        def delete_entitlement(plan_code, feature_code)
          response = connection.destroy(entitlements_uri(plan_code, feature_code), identifier: nil)
          JSON.parse(response.to_json, object_class: OpenStruct).entitlement
        end

        def delete_entitlement_privilege(plan_code, feature_code, privilege_code)
          response = connection.destroy(
            entitlements_uri(plan_code, feature_code, "privileges/#{privilege_code}"),
            identifier: nil,
          )
          JSON.parse(response.to_json, object_class: OpenStruct).entitlement
        end

        def whitelist_params(params)
          result_hash = {
            name: params[:name],
            invoice_display_name: params[:invoice_display_name],
            code: params[:code],
            interval: params[:interval],
            description: params[:description],
            amount_cents: params[:amount_cents],
            amount_currency: params[:amount_currency],
            trial_period: params[:trial_period],
            pay_in_advance: params[:pay_in_advance],
            bill_charges_monthly: params[:bill_charges_monthly],
            tax_codes: params[:tax_codes],
            cascade_updates: params[:cascade_updates],
          }.compact

          whitelist_charges(params[:charges]).tap do |charges|
            result_hash[:charges] = charges unless charges.empty?
          end

          whitelist_minimum_commitment(params[:minimum_commitment]).tap do |minimum_commitment|
            result_hash[:minimum_commitment] = minimum_commitment
          end

          whitelist_usage_thresholds(params[:usage_thresholds]).tap do |usage_thresholds|
            result_hash[:usage_thresholds] = usage_thresholds unless usage_thresholds.empty?
          end

          { root_name => result_hash }
        end

        def whitelist_minimum_commitment(minimum_commitment)
          minimum_commitment&.slice(
            :amount_cents,
            :invoice_display_name,
            :tax_codes,
          )
        end

        def whitelist_charges(charges)
          processed_charges = []

          charges&.each do |c|
            result = (c || {}).slice(
              :id,
              :billable_metric_id,
              :charge_model,
              :pay_in_advance,
              :invoiceable,
              :regroup_paid_fees,
              :invoice_display_name,
              :min_amount_cents,
              :properties,
              :filters,
              :tax_codes,
              :applied_pricing_unit,
            )

            processed_charges << result unless result.empty?
          end

          processed_charges
        end

        def whitelist_usage_thresholds(usage_thresholds)
          processed_usage_thresholds = []

          usage_thresholds&.each do |c|
            result = (c || {}).slice(
              :id,
              :threshold_display_name,
              :amount_cents,
              :recurring,
            )

            processed_usage_thresholds << result unless result.empty?
          end

          processed_usage_thresholds
        end

        def whitelist_entitlements_params(params)
          {
            entitlements: params,
          }
        end

        private

        def entitlements_uri(plan_code, feature_code = nil, action = nil)
          url = "#{client.base_api_url}#{api_resource}/#{plan_code}/entitlements"
          url += "/#{feature_code}" if feature_code
          url += "/#{action}" if action
          URI(url)
        end
      end
    end
  end
end
