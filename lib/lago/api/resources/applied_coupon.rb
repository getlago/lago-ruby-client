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
              customer_id: params[:customer_id],
              coupon_code: params[:coupon_code],
              amount_cents: params[:amount_cents],
              amount_currency: params[:amount_currency]
            }
          }
        end
      end
    end
  end
end
