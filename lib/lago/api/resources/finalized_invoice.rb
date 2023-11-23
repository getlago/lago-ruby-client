# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class FinalizedInvoice < Base
        def api_resource
          'analytics/finalized_invoices'
        end

        def root_name
          'finalized_invoice'
        end
      end
    end
  end
end
