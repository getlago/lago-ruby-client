# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      class Order < Base
        undef_method :create, :update, :destroy

        def api_resource
          'orders'
        end

        def root_name
          'order'
        end

        def execute(order_id, params = {})
          path = "/api/v1/orders/#{order_id}/execute"
          payload = whitelist_params(params)
          response = connection.post(payload, path)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def whitelist_params(params)
          result = {
            execution_mode: params[:execution_mode],
          }.compact

          return {} if result.empty?

          { root_name => result }
        end
      end
    end
  end
end
