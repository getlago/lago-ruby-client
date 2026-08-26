# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      class OrderForm < Base
        undef_method :create, :update, :destroy

        def api_resource
          'order_forms'
        end

        def root_name
          'order_form'
        end

        def mark_as_signed(order_form_id, params = {})
          path = "/api/v1/order_forms/#{order_form_id}/mark_as_signed"
          payload = whitelist_params(params)
          response = connection.post(payload, path)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def void(order_form_id)
          path = "/api/v1/order_forms/#{order_form_id}/void"
          response = connection.post({}, path)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def whitelist_params(params)
          result = {
            signed_document: params[:signed_document],
            execution_mode: params[:execution_mode],
            execute_at: params[:execute_at],
          }.compact

          return {} if result.empty?

          { root_name => result }
        end
      end
    end
  end
end
