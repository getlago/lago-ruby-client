# frozen_string_literal: true

module Lago
  module Api
    module V2
      module ErrorDetails
        # The HTTP status is separate from the v2 error code in the JSON body.
        def http_status
          error_code
        end

        def code
          parsed_error['code']
        end

        def details
          parsed_error.fetch('details', [])
        end

        private

        def parsed_error
          return {} if error_body.nil?

          body = json_message
          body.is_a?(Hash) ? body : {}
        rescue JSON::ParserError
          {}
        end
      end
    end
  end
end
