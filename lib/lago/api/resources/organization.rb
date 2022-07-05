# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Organization < Base
        def api_resource
          'organizations'
        end

        def root_name
          'organization'
        end

        def whitelist_params(params)
          {
            root_name => {
              webhook_url: params[:webhook_url],
              vat_rate: params[:vat_rate],
              country: params[:country],
              address_line1: params[:address_line1],
              address_line2: params[:address_line2],
              state: params[:state],
              zipcode: params[:zipcode],
              email: params[:email],
              city: params[:city],
              legal_name: params[:legal_name],
              legal_number: params[:legal_number],
              invoice_footer: params[:invoice_footer]
            }
          }
        end
      end
    end
  end
end
