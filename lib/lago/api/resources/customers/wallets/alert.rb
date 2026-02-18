# frozen_string_literal: true

module Lago
  module Api
    module Resources
      module Customers
        class Wallets < Lago::Api::Resources::Nested
          class Alert < Base
            def api_resource(customer_id, wallet_code)
              "#{base_api_resource(customer_id, wallet_code)}/alerts"
            end

            def root_name
              'alert'
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
