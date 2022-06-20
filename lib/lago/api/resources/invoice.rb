# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Invoice < Base
        def api_resource
          'invoices'
        end

        def root_name
          'invoice'
        end

        def whitelist_params(params)
          {
            root_name => {
              status: params[:status]
            }
          }
        end
      end
    end
  end
end
