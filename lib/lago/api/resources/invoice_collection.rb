# frozen_string_literal: true

require 'lago/api/resources/base'

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
