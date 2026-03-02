# frozen_string_literal: true

require 'lago/api/resources/base'
require 'lago/api/resources/customers/wallets/whitelist_params'

module Lago
  module Api
    module Resources
      module Customers
        class Wallet < Resources::Base
          def initialize(client, resource_id)
            super(client)
            @resource_id = resource_id
          end

          def api_resource
            "customers/#{resource_id}/wallets"
          end

          def root_name
            'wallet'
          end

          def whitelist_params(params)
            Wallets::WhitelistParams.new(params).whitelist
          end

          private

          attr_reader :resource_id
        end
      end
    end
  end
end
