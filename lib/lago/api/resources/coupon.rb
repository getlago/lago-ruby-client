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
              percentage_rate: params[:percentage_rate],
              coupon_type: params[:coupon_type],
              reusable: params[:reusable],
              frequency: params[:frequency],
              frequency_duration: params[:frequency_duration],
              expiration: params[:expiration],
              expiration_at: params[:expiration_at],
            }.compact,
          }
        end
      end
    end
  end
end
