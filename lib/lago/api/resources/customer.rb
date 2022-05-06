# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Customer < Base
        def api_resource
          'customers'
        end

        def root_name
          'customer'
        end

        def whitelist_params(params)
          {
            root_name => {
              customer_id: params[:customer_id],
              address_line1: params[:address_line1],
              address_line2: params[:address_line2],
              city: params[:city],
              country: params[:country],
              email: params[:email],
              legal_name: params[:legal_name],
              legal_number: params[:legal_number],
              logo_url: params[:logo_url],
              name: params[:name],
              phone: params[:phone],
              state: params[:state],
              url: params[:url],
              vat_rate: params[:vat_rate],
              zipcode: params[:zipcode]
            }
          }
        end
      end
    end
  end
end
