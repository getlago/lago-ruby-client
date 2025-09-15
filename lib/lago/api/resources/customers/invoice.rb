# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      module Customers
        class Invoice < Base
          def api_resource
            "#{base_api_resource}/invoices"
          end

          def root_name
            'invoice'
          end
        end
      end
    end
  end
end
