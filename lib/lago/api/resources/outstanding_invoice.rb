# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class OutstandingInvoice < Base
        def api_resource
          'analytics/outstanding_invoices'
        end

        def root_name
          'outstanding_invoice'
        end
      end
    end
  end
end
