# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class SecurityLog < Base
          # GET /security_logs
          def get_all(options = {})
            request('GET', '/security_logs', query: options)
          end

          # GET /security_logs/{log_id}
          def get(log_id, options = {})
            request('GET', '/security_logs/{log_id}', result_key: 'security_log', query: options, log_id:)
          end
        end
      end
    end
  end
end
