# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class CreditNote < Base
        def api_resource
          'credit_notes'
        end

        def root_name
          'credit_note'
        end

        def whitelist_params(params)
          result_hash = {
            invoice_id: params[:invoice_id],
            reason: params[:reason],
            refund_status: params[:refund_status]
          }.compact

          whitelist_items(params[:items] || []).tap do |items|
            result_hash[:items] = items unless items.empty?
          end

          { root_name => result_hash }
        end

        def whitelist_items(items)
          items.each_with_object([]) do |item, result|
            filtered_item = (item || {}).slice(
              :fee_id, :amount_cents
            )

            result << filtered_item unless filtered_item.empty?
          end
        end

        def download(credit_note_id)
          path = "/api/v1/credit_notes/#{credit_note_id}/download"
          response = connection.post({}, path)

          return response unless response.is_a?(Hash)

          JSON.parse(response.to_json, object_class: OpenStruct).credit_note
        end

        def void(credit_note_id)
          path = "/api/v1/credit_notes/#{credit_note_id}/void"
          response = connection.put(
            path,
            identifier: nil,
            body: {}
          )

          JSON.parse(response.to_json, object_class: OpenStruct).credit_note
        end
      end
    end
  end
end
