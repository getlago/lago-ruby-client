# frozen_string_literal: true

module Lago
  module Api
    module Resources
      module Customers
        class Wallets < Lago::Api::Resources::Base
          class Base < Lago::Api::Resources::Base
            attr_reader :connection

            def initialize(client)
              super(client)
              @connection = Lago::Api::Connection.new(client.api_key, client.base_api_url)
            end

            def base_api_resource(customer_id, wallet_code)
              URI.join(client.base_api_url, "customers/#{customer_id}/wallets/#{wallet_code}")
            end
          end
        end
      end
    end
  end
end
