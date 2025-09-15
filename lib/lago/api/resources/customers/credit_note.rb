# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      module Customers
        class CreditNote < Base
          def api_resource
            "#{base_api_resource}/credit_notes"
          end

          def root_name
            'credit_note'
          end
        end
      end
    end
  end
end
