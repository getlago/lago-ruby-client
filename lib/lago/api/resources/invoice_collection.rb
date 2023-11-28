# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class InvoiceCollection < Base
        def api_resource
          'analytics/invoice_collection'
        end

        def root_name
          'invoice_collection'
        end
      end
    end
  end
end
