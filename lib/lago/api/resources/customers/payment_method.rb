# frozen_string_literal: true

require 'lago/api/resources/customers/base'

module Lago
  module Api
    module Resources
      module Customers
        class PaymentMethod < Base
          def api_resource
            "#{base_api_resource}/payment_methods"
          end

          def root_name
            'payment_method'
          end

          def destroy(id, options: nil)
            response = connection.destroy(identifier: id, options:)[root_name]

            JSON.parse(response.to_json, object_class: OpenStruct)
          end

          # rubocop:disable Naming/AccessorMethodName
          def set_as_default(payment_method_id)
            path = "/api/v1/#{api_resource}/#{payment_method_id}/set_as_default"
            response = connection.put(path, identifier: nil, body: {})[root_name]

            JSON.parse(response.to_json, object_class: OpenStruct)
          end
          # rubocop:enable Naming/AccessorMethodName
        end
      end
    end
  end
end
