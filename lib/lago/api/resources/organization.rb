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
          result_hash = {
            webhook_url: params[:webhook_url],
            country: params[:country],
            address_line1: params[:address_line1],
            address_line2: params[:address_line2],
            state: params[:state],
            zipcode: params[:zipcode],
            email: params[:email],
            city: params[:city],
            legal_name: params[:legal_name],
            legal_number: params[:legal_number],
            timezone: params[:timezone],
          }.compact

          whitelist_billing_configuration(params[:billing_configuration]).tap do |config|
            result_hash[:billing_configuration] = config unless config.empty?
          end

          { root_name => result_hash }
        end

        def whitelist_billing_configuration(billing_params)
          (billing_params || {}).slice(
            :invoice_footer,
            :invoice_grace_period,
            :vat_rate,
            :document_locale,
          )
        end
      end
    end
  end
end
