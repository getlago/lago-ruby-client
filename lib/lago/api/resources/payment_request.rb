# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class PaymentRequest < Base
        def api_resource
          'payment_requests'
        end

        def root_name
          'payment_request'
        end
      end
    end
  end
end
