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
          {
            root_name => {
              external_customer_id: params[:external_customer_id],
              rate_amount: params[:rate_amount],
              name: params[:name],
              paid_credits: params[:paid_credits],
              granted_credits: params[:granted_credits],
              currency: params[:currency],
              expiration_at: params[:expiration_at],
            }.compact,
          }
        end
      end
    end
  end
end
