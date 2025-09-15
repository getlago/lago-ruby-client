# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      module Customers
        class PaymentRequest < Base
          def api_resource
            "#{base_api_resource}/payment_requests"
          end

          def root_name
            'payment_request'
          end
        end
      end
    end
  end
end
