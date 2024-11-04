# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class BillableMetric < Base
        def api_resource
          'billable_metrics'
        end

        def root_name
          'billable_metric'
        end

        def evaluate_expression(params)
          uri = URI("#{client.base_api_url}#{api_resource}/evaluate_expression")

          payload = whitelist_evalute_expression_params(params)
          response = connection.post(payload, uri)['expression_result']

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def whitelist_params(params)
          {
            root_name => {
              name: params[:name],
              code: params[:code],
              description: params[:description],
              recurring: params[:recurring],
              aggregation_type: params[:aggregation_type],
              weighted_interval: params[:weighted_interval],
              field_name: params[:field_name],
              expression: params[:expression],
              filters: params[:filters],
              rounding_function: params[:rounding_function],
              rounding_precision: params[:rounding_precision],
            }.compact,
          }
        end

        def whitelist_evalute_expression_params(params)
          event = params[:event] || {}

          {
            expression: params[:expression],
            event: {
              code: event[:code],
              timestamp: event[:timestamp],
              properties: event[:properties],
            }.compact,
          }
        end
      end
    end
  end
end
