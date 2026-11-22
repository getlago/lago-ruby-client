# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class PaymentReceipt < Base
          # GET /payment_receipts
          def get_all(options = {})
            request('GET', '/payment_receipts', query: options)
          end

          # GET /payment_receipts/{lago_id}
          def get(lago_id, options = {})
            request('GET', '/payment_receipts/{lago_id}', result_key: 'payment_receipt', query: options, lago_id:)
          end

          # POST /payment_receipts/{lago_id}/resend_email
          def resend_email(lago_id, params = {})
            request('POST', '/payment_receipts/{lago_id}/resend_email', params:, lago_id:)
          end
        end
      end
    end
  end
end
