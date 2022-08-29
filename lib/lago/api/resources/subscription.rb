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
              external_customer_id: params[:external_customer_id],
              plan_code: params[:plan_code],
              name: params[:name],
              external_id: params[:external_id],
              billing_time: params[:billing_time]
            }.compact
          }
        end
      end
    end
  end
end
