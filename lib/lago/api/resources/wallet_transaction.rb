# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      class WalletTransaction < Base
        def api_resource
          'wallet_transactions'
        end

        def root_name
          'wallet_transactions'
        end

        def get_all(wallet_id, options = {})
          path = "/api/v1/wallets/#{wallet_id}/wallet_transactions"
          response = connection.get_all(options, path)

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def payment_url(wallet_transaction_id)
          path = "/api/v1/wallet_transactions/#{wallet_transaction_id}/payment_url"
          response = connection.post({}, path)['wallet_transaction_payment_details']

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def whitelist_params(params)
          {
            'wallet_transaction' => params.compact.slice(
              :wallet_id,
              :name,
              :paid_credits,
              :granted_credits,
              :voided_credits,
              :invoice_requires_successful_payment,
              :ignore_paid_top_up_limits,
              :metadata,
            )
          }
        end
      end
    end
  end
end
