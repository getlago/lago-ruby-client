# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Fee < Base
        def api_resource
          'fees'
        end

        def root_name
          'fee'
        end

        def whitelist_params(params)
          {
            root_name => {
              payment_status: params[:payment_status],
            },
          }
        end
      end
    end
  end
end
