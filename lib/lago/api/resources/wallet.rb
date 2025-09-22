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
          result_hash = params.compact.slice(
            :external_customer_id,
            :rate_amount,
            :name,
            :paid_credits,
            :granted_credits,
            :currency,
            :expiration_at,
            :transaction_metadata,
            :invoice_requires_successful_payment,
            :ignore_paid_top_up_limits_on_creation,
            :transaction_name,
            :paid_top_up_min_amount_cents,
            :paid_top_up_max_amount_cents
          )

          recurring_rules = whitelist_recurring_rules(params[:recurring_transaction_rules])
          result_hash[:recurring_transaction_rules] = recurring_rules if recurring_rules.any?

          applies_to = whitelist_applies_to(params[:applies_to])
          result_hash[:applies_to] = applies_to if applies_to.any?

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
              :transaction_metadata,
              :transaction_name,
              :ignore_paid_top_up_limits
            )

            processed_rules << result unless result.empty?
          end

          processed_rules
        end

        def whitelist_applies_to(applies_to_params)
          (applies_to_params || {}).slice(:fee_types, :billable_metric_codes)
        end
      end
    end
  end
end
