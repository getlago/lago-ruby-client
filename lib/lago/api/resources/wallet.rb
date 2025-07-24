# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      class Wallet < Base
        def api_resource
          'wallets'
        end

        def root_name
          'wallet'
        end

        def whitelist_params(params)
          result_hash = {
            external_customer_id: params[:external_customer_id],
            rate_amount: params[:rate_amount],
            name: params[:name],
            paid_credits: params[:paid_credits],
            granted_credits: params[:granted_credits],
            currency: params[:currency],
            expiration_at: params[:expiration_at],
            transaction_metadata: params[:transaction_metadata],
            invoice_requires_successful_payment: params[:invoice_requires_successful_payment],
          }.compact

          recurring_rules = whitelist_recurring_rules(params[:recurring_transaction_rules])
          result_hash[:recurring_transaction_rules] = recurring_rules unless recurring_rules.empty?

          applies_to = whitelist_applies_to(params[:applies_to])
          result_hash[:applies_to] = applies_to unless applies_to.empty?

          { root_name => result_hash }
        end

        def whitelist_recurring_rules(rules)
          processed_rules = []

          (rules || []).each do |r|
            result = (r || {}).slice(
              :lago_id,
              :paid_credits,
              :granted_credits,
              :threshold_credits,
              :invoice_requires_successful_payment,
              :trigger,
              :interval,
              :method,
              :started_at,
              :expiration_at,
              :target_ongoing_balance,
              :transaction_metadata
            )

            processed_rules << result unless result.empty?
          end

          processed_rules
        end

        def whitelist_applies_to(applies_to_params)
          (applies_to_params || {}).slice(:fee_types)
        end
      end
    end
  end
end
