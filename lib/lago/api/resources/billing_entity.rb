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

        def create(params)
          payload = whitelist_create_params(params)
          response = connection.post(payload)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def update(params, billing_entity_code)
          payload = whitelist_update_params(params)
          response = connection.put(identifier: billing_entity_code, body: payload)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def destroy(billing_entity_code)
          raise NotImplementedError
        end

        def whitelist_create_params(params)
          result_params = params.slice(
            :code,
            :name,
            :address_line1,
            :address_line2,
            :city,
            :state,
            :zipcode,
            :country,
            :email,
            :phone,
            :default_currency,
            :timezone,
            :document_numbering,
            :document_number_prefix,
            :finalize_zero_amount_invoice,
            :net_payment_term,
            :eu_tax_management,
            :logo,
            :legal_name,
            :legal_number,
            :tax_identification_number,
            :email_settings
          ).compact

          whitelist_billing_configuration(params[:billing_configuration]).tap do |config|
            result_params[:billing_configuration] = config unless config.empty?
          end

          { root_name => result_params }
        end

        def whitelist_billing_configuration(billing_params)
          (billing_params || {}).slice(
            :invoice_footer,
            :invoice_grace_period,
            :document_locale,
          )
        end

        def whitelist_update_params(params)
          result_params = whitelist_create_params(params).dup

          result_params.delete(:code)
          result_params[:tax_codes] = params[:tax_codes] if params.key?(:tax_codes)
          result_params[:invoice_custom_section_codes] = params[:invoice_custom_section_codes] if params.key?(:invoice_custom_section_codes)

          { root_name => result_params }
        end
      end
    end
  end
end
