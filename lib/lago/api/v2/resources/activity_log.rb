# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class ActivityLog < Base
          # GET /activity_logs
          def get_all(options = {})
            request('GET', '/activity_logs', query: options)
          end

          # GET /activity_logs/{activity_id}
          def get(activity_id, options = {})
            request('GET', '/activity_logs/{activity_id}', result_key: 'activity_log', query: options, activity_id:)
          end
        end
      end
    end
  end
end
