# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class ApiLog < Base
          # GET /api_logs
          def get_all(options = {})
            request('GET', '/api_logs', query: options)
          end

          # GET /api_logs/{request_id}
          def get(request_id, options = {})
            request('GET', '/api_logs/{request_id}', result_key: 'api_log', query: options, request_id:)
          end
        end
      end
    end
  end
end
