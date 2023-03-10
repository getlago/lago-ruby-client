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

          JSON.parse(response.to_json, object_class: OpenStruct).invoice
        end

        def refresh(invoice_id)
          path = "/api/v1/invoices/#{invoice_id}/refresh"
          response = connection.put(path, identifier: nil, body: {})

          JSON.parse(response.to_json, object_class: OpenStruct).invoice
        end

        def finalize(invoice_id)
          path = "/api/v1/invoices/#{invoice_id}/finalize"
          response = connection.put(path, identifier: nil, body: {})

          JSON.parse(response.to_json, object_class: OpenStruct).invoice
        end

        def retry_payment(invoice_id)
          path = "/api/v1/invoices/#{invoice_id}/retry_payment"
          response = connection.post({}, path)

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def whitelist_params(params)
          result = {
            payment_status: params[:payment_status],
          }

          metadata = whitelist_metadata(params[:metadata])
          result[:metadata] = metadata unless metadata.empty?

          { root_name => result }
        end

        def whitelist_metadata(metadata)
          processed_metadata = []

          metadata.each do |m|
            result = (m || {}).slice(:id, :key, :value)

            processed_metadata << result unless result.empty?
          end

          processed_metadata
        end
      end
    end
  end
end
