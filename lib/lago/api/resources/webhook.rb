# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Webhook < Base
        def api_resource
          'webhooks'
        end

        def public_key
          path = '/api/v1/webhooks/public_key'

          webhooks_public_key = connection.get(path, identifier: nil)
          OpenSSL::PKey::RSA.new(Base64.decode64(webhooks_public_key))
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
