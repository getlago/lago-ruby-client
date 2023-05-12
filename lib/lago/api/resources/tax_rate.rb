# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class TaxRate < Base
        def api_resource
          'tax_rates'
        end

        def root_name
          'tax_rate'
        end

        def whitelist_params(params)
          {
            root_name => {
              name: params[:name],
              code: params[:code],
              value: params[:value],
              description: params[:description],
              applied_by_default: params[:applied_by_default],
            }.compact
          }
        end
      end
    end
  end
end
