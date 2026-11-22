# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class CreditNote < Base
          # GET /credit_notes
          def get_all(options = {})
            request('GET', '/credit_notes', query: options)
          end

          # POST /credit_notes
          def create(params)
            request('POST', '/credit_notes', params:, body_root: 'credit_note', result_key: 'credit_note')
          end

          # GET /credit_notes/{lago_id}
          def get(lago_id, options = {})
            request('GET', '/credit_notes/{lago_id}', result_key: 'credit_note', query: options, lago_id:)
          end

          # PUT /credit_notes/{lago_id}
          def update(params, lago_id)
            request(
              'PUT',
              '/credit_notes/{lago_id}',
              params:,
              body_root: 'credit_note',
              result_key: 'credit_note',
              lago_id:,
            )
          end

          # PATCH /credit_notes/{lago_id}
          def patch(params, lago_id)
            request(
              'PATCH',
              '/credit_notes/{lago_id}',
              params:,
              body_root: 'credit_note',
              result_key: 'credit_note',
              lago_id:,
            )
          end

          # POST /credit_notes/estimate
          def estimate(params)
            request(
              'POST',
              '/credit_notes/estimate',
              params:,
              body_root: 'credit_note',
              result_key: 'estimated_credit_note',
            )
          end

          # POST /credit_notes/{lago_id}/download_pdf
          def download_pdf(lago_id)
            request('POST', '/credit_notes/{lago_id}/download_pdf', result_key: 'credit_note', lago_id:)
          end

          # POST /credit_notes/{lago_id}/download_xml
          def download_xml(lago_id)
            request('POST', '/credit_notes/{lago_id}/download_xml', result_key: 'credit_note', lago_id:)
          end

          # POST /credit_notes/{lago_id}/resend_email
          def resend_email(lago_id, params = {})
            request('POST', '/credit_notes/{lago_id}/resend_email', params:, lago_id:)
          end

          # PUT /credit_notes/{lago_id}/void
          def void(lago_id)
            request('PUT', '/credit_notes/{lago_id}/void', result_key: 'credit_note', lago_id:)
          end

          # POST /credit_notes/{credit_note_id}/metadata
          def replace_metadata(credit_note_id, params = {})
            request(
              'POST',
              '/credit_notes/{credit_note_id}/metadata',
              params:,
              body_root: 'metadata',
              result_key: 'metadata',
              credit_note_id:,
            )
          end

          # PUT /credit_notes/{credit_note_id}/metadata
          def update_metadata(credit_note_id, params = {})
            request(
              'PUT',
              '/credit_notes/{credit_note_id}/metadata',
              params:,
              body_root: 'metadata',
              result_key: 'metadata',
              credit_note_id:,
            )
          end

          # PATCH /credit_notes/{credit_note_id}/metadata
          def patch_metadata(credit_note_id, params = {})
            request(
              'PATCH',
              '/credit_notes/{credit_note_id}/metadata',
              params:,
              body_root: 'metadata',
              result_key: 'metadata',
              credit_note_id:,
            )
          end

          # DELETE /credit_notes/{credit_note_id}/metadata
          def destroy_metadata(credit_note_id)
            request('DELETE', '/credit_notes/{credit_note_id}/metadata', result_key: 'metadata', credit_note_id:)
          end

          # DELETE /credit_notes/{credit_note_id}/metadata/{key}
          def destroy_metadata_key(credit_note_id, key)
            request(
              'DELETE',
              '/credit_notes/{credit_note_id}/metadata/{key}',
              result_key: 'metadata',
              credit_note_id:,
              key:,
            )
          end
        end
      end
    end
  end
end
