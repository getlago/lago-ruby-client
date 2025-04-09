# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class BillingEntity < Base
        def api_resource
          'billing_entities'
        end

        def root_name
          'billing_entity'
        end

        def whitelist_params(params)
        end
      end
    end
  end
end
