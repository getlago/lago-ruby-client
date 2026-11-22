# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class PaymentRequest < Base
          # GET /payment_requests
          def get_all(options = {})
            request('GET', '/payment_requests', query: options)
          end

          # POST /payment_requests
          def create(params)
            request('POST', '/payment_requests', params:, body_root: 'payment_request', result_key: 'payment_request')
          end

          # GET /payment_requests/{lago_id}
          def get(lago_id, options = {})
            request('GET', '/payment_requests/{lago_id}', result_key: 'payment_request', query: options, lago_id:)
          end
        end
      end
    end
  end
end
