# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class PaymentRequest < Base
        def api_resource
          'payment_requests'
        end

        def root_name
          'payment_request'
        end

        def whitelist_params(params)
          result_hash = {
            email: params[:email],
            external_customer_id: params[:external_customer_id],
            payment_status: params[:payment_status],
            lago_invoice_ids: params[:lago_invoice_ids]
          }.compact

          { root_name => result_hash }
        end
      end
    end
  end
end
