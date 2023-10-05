# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class AddOn < Base
        def api_resource
          'add_ons'
        end

        def root_name
          'add_on'
        end

        def whitelist_params(params)
          {
            root_name => {
              name: params[:name],
              invoice_display_name: params[:invoice_display_name],
              code: params[:code],
              description: params[:description],
              amount_cents: params[:amount_cents],
              amount_currency: params[:amount_currency],
              tax_codes: params[:tax_codes],
            }.compact
          }
        end
      end
    end
  end
end
