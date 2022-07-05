# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Coupon < Base
        def api_resource
          'coupons'
        end

        def root_name
          'coupon'
        end

        def whitelist_params(params)
          {
            root_name => {
              name: params[:name],
              code: params[:code],
              amount_cents: params[:amount_cents],
              amount_currency: params[:amount_currency],
              expiration: params[:expiration],
              expiration_duration: params[:expiration_duration]
            }
          }
        end
      end
    end
  end
end
