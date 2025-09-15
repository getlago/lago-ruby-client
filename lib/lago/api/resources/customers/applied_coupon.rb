# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      module Customers
        class AppliedCoupon < Base
          def api_resource
            "#{base_api_resource}/applied_coupons"
          end

          def root_name
            'applied_coupon'
          end
        end
      end
    end
  end
end
