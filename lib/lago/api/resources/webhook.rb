# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Webhook < Base
        def api_resource
          'webhooks'
        end

        def root_name
          'webhook'
        end

        def public_key
          path = '/api/v1/webhooks/public_key'

          response = connection.get(path, identifier: nil)

          # Adding fallback for text/plain Content-Type response in older versions
          if response.is_a?(String)
            OpenSSL::PKey::RSA.new(Base64.decode64(response))
          else
            webhook_details = JSON.parse(response[root_name].to_json, object_class: OpenStruct)
            OpenSSL::PKey::RSA.new(Base64.decode64(webhook_details.public_key))
          end
        end

        def valid_signature?(signature, webhook_payload, cached_key = public_key)
          decoded_signature = JWT.decode(
            signature,
            cached_key,
            true,
            {
              algorithm: 'RS256',
              iss: client.api_url || Lago::Api::BASE_URL,
              verify_iss: true,
            },
          ).first

          decoded_signature['data'] == webhook_payload.to_json
        rescue JWT::InvalidIssuerError, JWT::VerificationError
          false
        end
      end
    end
  end
end
