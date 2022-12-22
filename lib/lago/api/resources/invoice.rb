# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Invoice < Base
        def api_resource
          'invoices'
        end

        def root_name
          'invoice'
        end

        def download(invoice_id)
          path = "/api/v1/invoices/#{invoice_id}/download"
          response = connection.post({}, path)

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def retry_payment(invoice_id)
          path = "/api/v1/invoices/#{invoice_id}/retry_payment"
          response = connection.post({}, path)

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def whitelist_params(params)
          {
            root_name => {
              payment_status: params[:payment_status],
            },
          }
        end
      end
    end
  end
end
