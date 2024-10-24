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
            }.compact,
          }
        end
      end
    end
  end
end
