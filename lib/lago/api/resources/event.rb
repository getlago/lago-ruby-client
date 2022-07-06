# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Event < Base
        def api_resource
          'events'
        end

        def root_name
          'event'
        end

        def create(params)
          payload = whitelist_params(params)
          connection.post(payload)
        end

        def whitelist_params(params)
          {
            root_name => {
              transaction_id: params[:transaction_id],
              customer_id: params[:customer_id],
              code: params[:code],
              timestamp: params[:timestamp],
              properties: params[:properties]
            }
          }
        end
      end
    end
  end
end
