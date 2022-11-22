# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class AppliedAddOn < Base
        def api_resource
          'applied_add_ons'
        end

        def root_name
          'applied_add_on'
        end

        def whitelist_params(params)
          {
            root_name => {
              external_customer_id: params[:external_customer_id],
              add_on_code: params[:add_on_code],
              amount_cents: params[:amount_cents],
              amount_currency: params[:amount_currency]
            }.compact
          }
        end
      end
    end
  end
end
