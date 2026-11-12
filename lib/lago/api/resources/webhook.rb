# frozen_string_literal: true

require 'lago/api/resources/base'

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

        def valid_standard_webhooks_signature?(raw_body, headers, secret)
          normalized_headers = headers.to_h.transform_keys { |key| key.to_s.downcase }
          # The gem stops at the first entry without a comma, so keep only well-formed entries.
          signature = normalized_headers['webhook-signature']
          if signature
            normalized_headers['webhook-signature'] = signature.to_s.split(' ').select { |s| s.include?(',') }.join(' ')
          end
          StandardWebhooks::Webhook.new(secret).verify(raw_body, normalized_headers)

          # verify returns the parsed body, which is falsy for a signed `null` body.
          true
        # The gem raises NoMethodError for a nil secret or a `v1` signature without a comma,
        # ArgumentError for a signature of another byte size, TypeError for a nil body,
        # JSON::ParserError for a signed non-JSON body and EncodingError for a non-ASCII
        # webhook-id with a binary body.
        rescue StandardWebhooks::StandardWebhooksError,
               NoMethodError,
               ArgumentError,
               TypeError,
               EncodingError,
               JSON::ParserError
          false
        end
      end
    end
  end
end
