# frozen_string_literal: true

require 'lago/api/resources/base'
require 'lago/api/resources/customers/wallets/whitelist_params'

module Lago
  module Api
    module Resources
      class Wallet < Base
        def api_resource
          'wallets'
        end

        def root_name
          'wallet'
        end

        def whitelist_params(params)
          Customers::Wallets::WhitelistParams.new(params).whitelist
        end

        def replace_metadata(wallet_id, metadata)
          path = "/api/v1/wallets/#{wallet_id}/metadata"
          payload = { metadata: whitelist_metadata(metadata) }
          response = connection.post(payload, path)

          response['metadata']
        end

        def merge_metadata(wallet_id, metadata)
          path = "/api/v1/wallets/#{wallet_id}/metadata"
          payload = { metadata: whitelist_metadata(metadata) }
          response = connection.patch(path, identifier: nil, body: payload)

          response['metadata']
        end

        def delete_all_metadata(wallet_id)
          path = "/api/v1/wallets/#{wallet_id}/metadata"
          response = connection.destroy(path, identifier: nil)

          response['metadata']
        end

        def delete_metadata_key(wallet_id, key)
          path = "/api/v1/wallets/#{wallet_id}/metadata/#{key}"
          response = connection.destroy(path, identifier: nil)

          response['metadata']
        end
      end
    end
  end
end
