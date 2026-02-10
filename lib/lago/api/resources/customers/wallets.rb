# frozen_string_literal: true

require 'lago/api/resources/base'
require 'lago/api/resources/customers/wallets/whitelist_params'

module Lago
  module Api
    module Resources
      module Customers
        class Wallets < Lago::Api::Resources::Base
          attr_reader :connection

          def initialize(client)
            super(client)
            @connection = Lago::Api::Connection.new(client.api_key, client.base_api_url)
          end

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

          def create(customer_id, params)
            payload = whitelist_params(params)
            path = api_resource(customer_id)
            response = connection.post(payload, path)[root_name]

            JSON.parse(response.to_json, object_class: OpenStruct)
          end

          def get(customer_id, wallet_code)
            path = api_resource(customer_id)
            response = connection.get(path, identifier: wallet_code)[root_name]

            JSON.parse(response.to_json, object_class: OpenStruct)
          end

          def update(customer_id, wallet_code, params)
            path = api_resource(customer_id)
            payload = whitelist_params(params)
            response = connection.put(path, identifier: wallet_code, body: payload)[root_name]

            JSON.parse(response.to_json, object_class: OpenStruct)
          end

          def destroy(customer_id, wallet_code)
            path = api_resource(customer_id)
            response = connection.destroy(path, identifier: wallet_code)[root_name]

            JSON.parse(response.to_json, object_class: OpenStruct)
          end

          def get_all(customer_id, options = {})
            path = api_resource(customer_id)
            response = connection.get_all(options, path)

            JSON.parse(response.to_json, object_class: OpenStruct)
          end
        end
      end
    end
  end
end
