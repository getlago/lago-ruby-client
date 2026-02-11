# frozen_string_literal: true

module Lago
  module Api
    module Resources
      module Customers
        class Wallets < Lago::Api::Resources::Base
          class Alert < Base
            def api_resource(customer_id, wallet_code)
              "#{base_api_resource(customer_id, wallet_code)}/alerts"
            end

            def root_name
              'alert'
            end

            def create(customer_id, wallet_code, params)
              path = api_resource(customer_id, wallet_code)
              payload = whitelist_create_params(params)
              response = connection.post(payload, path)[root_name]

              JSON.parse(response.to_json, object_class: OpenStruct)
            end

            def get(customer_id, wallet_code, alert_code)
              path = api_resource(customer_id, wallet_code)
              response = connection.get(path, identifier: alert_code)[root_name]

              JSON.parse(response.to_json, object_class: OpenStruct)
            end

            def update(customer_id, wallet_code, alert_code, params)
              path = api_resource(customer_id, wallet_code)
              payload = whitelist_update_params(params)
              response = connection.put(path, identifier: alert_code, body: payload)[root_name]

              JSON.parse(response.to_json, object_class: OpenStruct)
            end

            def destroy(customer_id, wallet_code, alert_code)
              path = api_resource(customer_id, wallet_code)
              response = connection.destroy(path, identifier: alert_code)[root_name]

              JSON.parse(response.to_json, object_class: OpenStruct)
            end

            def get_all(customer_id, wallet_code, options = {})
              path = api_resource(customer_id, wallet_code)
              response = connection.get_all(options, path)

              JSON.parse(response.to_json, object_class: OpenStruct)
            end

            def whitelist_create_params(params)
              {
                alert: {
                  alert_type: params[:alert_type],
                  name: params[:name],
                  code: params[:code],
                  thresholds: params[:thresholds],
                }.compact,
              }
            end

            def whitelist_update_params(params)
              {
                alert: {
                  name: params[:name],
                  code: params[:code],
                  thresholds: params[:thresholds],
                }.compact,
              }
            end

            def whitelist_thresholds(params)
              (params || []).map do |p|
                (p || {}).slice(:code, :value, :recurring)
              end
            end
          end
        end
      end
    end
  end
end
