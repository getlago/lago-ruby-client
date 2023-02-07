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
          result_hash = {
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
          }.compact

          whitelist_limitations(params[:applies_to]).tap do |limitations|
            result_hash[:applies_to] = limitations unless limitations.empty?
          end

          { root_name => result_hash }
        end

        def whitelist_limitations(limitation_params)
          (limitation_params || {}).slice(:plan_codes)
        end
      end
    end
  end
end
