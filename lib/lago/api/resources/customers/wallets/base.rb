# frozen_string_literal: true

module Lago
  module Api
    module Resources
      module Customers
        class Wallets
          class Base < Lago::Api::Resources::Base
            def base_api_resource(customer_id, wallet_code)
              URI.join(client.base_api_url, "customers/#{customer_id}/wallets/#{wallet_code}")
            end
          end
        end
      end
    end
  end
end
