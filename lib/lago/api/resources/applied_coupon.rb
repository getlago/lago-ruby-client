# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class AppliedCoupon < Base
        def api_resource
          'applied_coupons'
        end

        def root_name
          'applied_coupon'
        end

        def whitelist_params(params)
          {
            root_name => {
              external_customer_id: params[:external_customer_id],
              coupon_code: params[:coupon_code],
              amount_cents: params[:amount_cents],
              percentage_rate: params[:percentage_rate],
              frequency: params[:frequency],
              frequency_duration: params[:frequency_duration],
              amount_currency: params[:amount_currency]
            }.compact
          }
        end
      end
    end
  end
end
