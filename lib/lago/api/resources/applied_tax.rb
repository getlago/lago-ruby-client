# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class AppliedTax < Base
        def api_resource
          'applied_tax'
        end

        def root_name
          'applied_tax'
        end

        def create(external_customer_id, params)
          path = "/api/v1/customers/#{external_customer_id}/applied_taxes"
          payload = whitelist_params(params)
          response = connection.post(payload, path)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def destroy(external_customer_id, tax_code)
          path = "/api/v1/customers/#{external_customer_id}/applied_taxes"
          response = connection.destroy(path, identifier: tax_code)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def whitelist_params(params)
          {
            root_name => {
              tax_code: params[:tax_code],
            }.compact,
          }
        end
      end
    end
  end
end
