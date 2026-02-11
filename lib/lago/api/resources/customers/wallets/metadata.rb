# frozen_string_literal: true

module Lago
  module Api
    module Resources
      module Customers
        class Wallets < Lago::Api::Resources::Nested
          class Metadata < Base
            def api_resource(customer_id, wallet_code)
              "#{base_api_resource(customer_id, wallet_code)}/metadata"
            end

            def replace(customer_id, wallet_code, metadata)
              path = api_resource(customer_id, wallet_code)
              payload = { metadata: whitelist_params(metadata) }
              response = connection.post(payload, path)

              response['metadata']
            end

            def merge(customer_id, wallet_code, metadata)
              path = api_resource(customer_id, wallet_code)
              payload = { metadata: whitelist_params(metadata) }
              response = connection.patch(path, identifier: nil, body: payload)

              response['metadata']
            end

            def delete_all(customer_id, wallet_code)
              path = api_resource(customer_id, wallet_code)
              response = connection.destroy(path, identifier: nil)

              response['metadata']
            end

            def delete_key(customer_id, wallet_code, key)
              path = api_resource(customer_id, wallet_code)
              response = connection.destroy(path, identifier: key)

              response['metadata']
            end

            def whitelist_params(params)
              params&.to_h&.transform_keys(&:to_s)&.transform_values { |v| v&.to_s }
            end
          end
        end
      end
    end
  end
end
