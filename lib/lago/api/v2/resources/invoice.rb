# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class Invoice < Base
          # GET /invoices
          def get_all(options = {})
            request('GET', '/invoices', query: options)
          end

          # GET /invoices/{lago_id}
          def get(lago_id, options = {})
            request('GET', '/invoices/{lago_id}', result_key: 'invoice', query: options, lago_id:)
          end

          # PUT /invoices/{lago_id}
          def update(params, lago_id)
            request('PUT', '/invoices/{lago_id}', params:, body_root: 'invoice', result_key: 'invoice', lago_id:)
          end

          # PATCH /invoices/{lago_id}
          def patch(params, lago_id)
            request('PATCH', '/invoices/{lago_id}', params:, body_root: 'invoice', result_key: 'invoice', lago_id:)
          end

          # DELETE /invoices/{lago_id}
          def destroy(lago_id)
            request('DELETE', '/invoices/{lago_id}', result_key: 'invoice', lago_id:)
          end

          # POST /invoices/{lago_id}/void
          def void(lago_id, params = {})
            request('POST', '/invoices/{lago_id}/void', params:, result_key: 'invoice', lago_id:)
          end

          # POST /invoices/{lago_id}/lose_dispute
          def lose_dispute(lago_id)
            request('POST', '/invoices/{lago_id}/lose_dispute', result_key: 'invoice', lago_id:)
          end

          # POST /invoices/{lago_id}/download_pdf
          def download_pdf(lago_id)
            request('POST', '/invoices/{lago_id}/download_pdf', result_key: 'invoice', lago_id:)
          end

          # POST /invoices/{lago_id}/resend_email
          def resend_email(lago_id, params = {})
            request('POST', '/invoices/{lago_id}/resend_email', params:, lago_id:)
          end

          # POST /invoices/{lago_id}/retry_taxes
          def retry_taxes(lago_id)
            request('POST', '/invoices/{lago_id}/retry_taxes', result_key: 'invoice', lago_id:)
          end

          # POST /invoices/{lago_id}/retry_payment
          def retry_payment(lago_id, params = {})
            request('POST', '/invoices/{lago_id}/retry_payment', params:, lago_id:)
          end

          # PUT /invoices/{lago_id}/finalize
          def finalize(lago_id)
            request('PUT', '/invoices/{lago_id}/finalize', result_key: 'invoice', lago_id:)
          end

          # PUT /invoices/{lago_id}/refresh
          def refresh(lago_id)
            request('PUT', '/invoices/{lago_id}/refresh', result_key: 'invoice', lago_id:)
          end

          # POST /invoices/{lago_id}/payment_url
          def payment_url(lago_id)
            request('POST', '/invoices/{lago_id}/payment_url', result_key: 'payment_url', lago_id:)
          end
        end
      end
    end
  end
end
