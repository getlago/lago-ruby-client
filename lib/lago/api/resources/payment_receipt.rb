# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class PaymentReceipt < Base
        def api_resource
          'payment_receipts'
        end

        def root_name
          'payment_receipt'
        end
      end
    end
  end
end
