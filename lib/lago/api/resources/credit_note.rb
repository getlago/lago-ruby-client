# frozen_string_literal: true

require 'lago/api/resources/base'

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
            refund_status: params[:refund_status],
            credit_amount_cents: params[:credit_amount_cents],
            refund_amount_cents: params[:refund_amount_cents],
            offset_amount_cents: params[:offset_amount_cents],
          }.compact

          whitelist_items(params[:items] || []).tap do |items|
            result_hash[:items] = items unless items.empty?
          end

          metadata = whitelist_metadata(params[:metadata])
          result_hash[:metadata] = metadata if metadata

          { root_name => result_hash }
        end

        def whitelist_metadata(metadata)
          metadata&.to_h&.transform_keys(&:to_s)&.transform_values { |v| v&.to_s }
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

        def estimate(params)
          uri = URI("#{client.base_api_url}#{api_resource}/estimate")

          payload = whitelist_estimate_params(params)
          response = connection.post(payload, uri)['estimated_credit_note']

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def whitelist_estimate_params(params)
          result_hash = { invoice_id: params[:invoice_id] }.compact

          whitelist_items(params[:items] || []).tap do |items|
            result_hash[:items] = items unless items.empty?
          end

          { root_name => result_hash }
        end

        def replace_metadata(credit_note_id, metadata)
          path = "/api/v1/credit_notes/#{credit_note_id}/metadata"
          payload = { metadata: whitelist_metadata(metadata) }
          response = connection.post(payload, path)

          response['metadata']
        end

        def merge_metadata(credit_note_id, metadata)
          path = "/api/v1/credit_notes/#{credit_note_id}/metadata"
          payload = { metadata: whitelist_metadata(metadata) }
          response = connection.patch(path, identifier: nil, body: payload)

          response['metadata']
        end

        def delete_all_metadata(credit_note_id)
          path = "/api/v1/credit_notes/#{credit_note_id}/metadata"
          response = connection.destroy(path, identifier: nil)

          response['metadata']
        end

        def delete_metadata_key(credit_note_id, key)
          path = "/api/v1/credit_notes/#{credit_note_id}/metadata/#{key}"
          response = connection.destroy(path, identifier: nil)

          response['metadata']
        end
      end
    end
  end
end
