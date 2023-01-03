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
          path = '/api/v1/webhooks/json_public_key'

          response = connection.get(path, identifier: nil)[root_name]

          webhook_details = JSON.parse(response.to_json, object_class: OpenStruct)

          OpenSSL::PKey::RSA.new(Base64.decode64(webhook_details.public_key))
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
