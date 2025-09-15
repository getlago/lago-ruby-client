# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      module Customers
        class Payment < Base
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
