# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Tax < Base
        def api_resource
          'taxes'
        end

        def root_name
          'tax'
        end

        def whitelist_params(params)
          {
            root_name => {
              name: params[:name],
              code: params[:code],
              rate: params[:rate],
              description: params[:description],
              applied_to_organization: params[:applied_to_organization],
            }.compact,
          }
        end
      end
    end
  end
end
