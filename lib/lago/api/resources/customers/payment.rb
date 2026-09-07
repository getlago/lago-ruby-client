# frozen_string_literal: true

require 'lago/api/resources/base'
require 'lago/api/resources/payment_filters'

module Lago
  module Api
    module Resources
      module Customers
        class Payment < Base
          include PaymentFilters

          def api_resource
            "#{base_api_resource}/payments"
          end

          def root_name
            'payment'
          end
        end
      end
    end
  end
end
