# frozen_string_literal: true

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
              :target_ongoing_balance,
              :transaction_metadata
            )

            processed_rules << result unless result.empty?
          end

          processed_rules
        end
      end
    end
  end
end
