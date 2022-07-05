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
              code: params[:code],
              description: params[:description],
              amount_cents: params[:amount_cents],
              amount_currency: params[:amount_currency]
            }
          }
        end
      end
    end
  end
end
