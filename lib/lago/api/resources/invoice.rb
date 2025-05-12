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

        def create(params)
          payload = one_off_params(params)
          response = connection.post(payload)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def download(invoice_id)
          path = "/api/v1/invoices/#{invoice_id}/download"
          response = connection.post({}, path)

          return response unless response.is_a?(Hash)

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

        def lose_dispute(invoice_id)
          path = "/api/v1/invoices/#{invoice_id}/lose_dispute"
          response = connection.put(path, identifier: nil, body: {})

          JSON.parse(response.to_json, object_class: OpenStruct).invoice
        end

        def retry_payment(invoice_id)
          path = "/api/v1/invoices/#{invoice_id}/retry_payment"
          response = connection.post({}, path)

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def retry(invoice_id)
          path = "/api/v1/invoices/#{invoice_id}/retry"
          response = connection.post({}, path)

          JSON.parse(response.to_json, object_class: OpenStruct).invoice
        end

        def payment_url(invoice_id)
          path = "/api/v1/invoices/#{invoice_id}/payment_url"
          response = connection.post({}, path)['invoice_payment_details']

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def preview(params)
          path = "/api/v1/invoices/preview"
          payload = params.slice(
            :customer, :plan_code, :subscription_at, :billing_time, :coupons, :subscriptions
          )
          response = connection.post(payload, path)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def whitelist_params(params)
          result = {
            payment_status: params[:payment_status],
            net_payment_term: params[:net_payment_term],
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

        def one_off_params(params)
          result = {
            external_customer_id: params[:external_customer_id],
            currency: params[:currency],
            net_payment_term: params[:net_payment_term],
            skip_psp: params[:skip_psp]
          }

          fees = whitelist_fees(params[:fees])
          result[:fees] = fees unless fees.empty?

          { root_name => result }
        end

        def whitelist_fees(fees)
          processed_fees = []

          fees.each do |f|
            result = (f || {}).slice(
              :add_on_code,
              :unit_amount_cents,
              :units,
              :description,
              :tax_codes,
              :invoice_display_name,
            )

            processed_fees << result unless result.empty?
          end

          processed_fees
        end
      end
    end
  end
end
