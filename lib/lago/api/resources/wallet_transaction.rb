# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class WalletTransaction < Base
        def api_resource
          'wallet_transactions'
        end

        def root_name
          'wallet_transaction'
        end

        def whitelist_params(params)
          {
            root_name => {
              wallet_id: params[:wallet_id],
              paid_credits: params[:paid_credits],
              granted_credits: params[:granted_credits]
            }.compact
          }
        end
      end
    end
  end
end
