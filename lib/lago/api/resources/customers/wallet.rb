# frozen_string_literal: true
# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      module Customers
        class Wallet < Base
          def api_resource
            "#{base_api_resource}/wallets"
          end

          def root_name
            'wallet'
          end
        end
      end
    end
  end
end
