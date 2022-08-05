# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Subscription < Base
        def api_resource
          'subscriptions'
        end

        def root_name
          'subscription'
        end

        def whitelist_params(params)
          {
            root_name => {
              customer_id: params[:customer_id],
              plan_code: params[:plan_code],
              name: params[:name],
              unique_id: params[:unique_id],
              subscription_id: params[:subscription_id]
            }.compact
          }
        end
      end
    end
  end
end
