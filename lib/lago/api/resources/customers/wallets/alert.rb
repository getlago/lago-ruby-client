# frozen_string_literal: true

module Lago
  module Api
    module Resources
      module Customers
        class Wallets < Lago::Api::Resources::Nested
          class Alert < Base
            def create_batch(customer_id, wallet_code, params)
              response = connection.post(
                whitelist_create_batch_params(params),
                api_resource(customer_id, wallet_code),
              )

              JSON.parse(response.to_json, object_class: OpenStruct).alerts
            end

            def destroy_all(customer_id, wallet_code)
              connection.destroy(
                api_resource(customer_id, wallet_code),
                identifier: nil,
              )

              nil
            end

            private

            def api_resource(customer_id, wallet_code)
              "#{base_api_resource(customer_id, wallet_code)}/alerts"
            end

            def root_name
              'alert'
            end

            def whitelist_create_params(params)
              { alert: create_alert_params(params) }
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

            def whitelist_create_batch_params(params)
              params = params.is_a?(Hash) ? params[:alerts] : params

              { alerts: (params || []).map { |alert| create_alert_params(alert) } }
            end

            def create_alert_params(params)
              {
                alert_type: params[:alert_type],
                name: params[:name],
                code: params[:code],
                thresholds: params[:thresholds],
              }.compact
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
