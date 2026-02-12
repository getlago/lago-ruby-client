# frozen_string_literal: true

require 'lago/api/resources/nested'
require 'lago/api/resources/customers/wallets/whitelist_params'

module Lago
  module Api
    module Resources
      module Customers
        class Wallets < Lago::Api::Resources::Nested
          def api_resource(customer_id)
            "#{client.base_api_url}customers/#{customer_id}/wallets"
          end

          def root_name
            'wallet'
          end

          def whitelist_params(params)
            Wallets::WhitelistParams.new(params).whitelist
          end

          def metadata
            Wallets::Metadata.new(client)
          end
        end
      end
    end
  end
end
