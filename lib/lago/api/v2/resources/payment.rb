# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class Payment < Base
          # GET /payments
          def get_all(options = {})
            request('GET', '/payments', query: options)
          end

          # POST /payments
          def create(params)
            request('POST', '/payments', params:, body_root: 'payment', result_key: 'payment')
          end

          # GET /payments/{lago_id}
          def get(lago_id, options = {})
            request('GET', '/payments/{lago_id}', result_key: 'payment', query: options, lago_id:)
          end
        end
      end
    end
  end
end
