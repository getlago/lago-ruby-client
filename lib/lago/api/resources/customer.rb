# frozen_string_literal: true

require 'lago/api/resources/base'

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

        def current_usage(
          external_customer_id, external_subscription_id, apply_taxes: nil,
          filter_by_charge_id: nil, filter_by_charge_code: nil, filter_by_group: nil, full_usage: nil
        ) # rubocop:disable Metrics/ParameterLists
          query_params = { external_subscription_id: external_subscription_id }
          query_params[:apply_taxes] = apply_taxes unless apply_taxes.nil?
          query_params[:filter_by_charge_id] = filter_by_charge_id unless filter_by_charge_id.nil?
          query_params[:filter_by_charge_code] = filter_by_charge_code unless filter_by_charge_code.nil?
          filter_by_group&.each { |k, v| query_params[:"filter_by_group[#{k}]"] = v }
          query_params[:full_usage] = full_usage unless full_usage.nil?
          query_string = URI.encode_www_form(query_params)

          uri = URI("#{client.base_api_url}#{api_resource}/#{external_customer_id}/current_usage?#{query_string}")
          connection.get(uri, identifier: nil)
        end

        def projected_usage(external_customer_id, external_subscription_id, apply_taxes: nil)
          query_params = { external_subscription_id: external_subscription_id }
          query_params[:apply_taxes] = apply_taxes unless apply_taxes.nil?
          query_string = URI.encode_www_form(query_params)

          uri = URI("#{client.base_api_url}#{api_resource}/#{external_customer_id}/projected_usage?#{query_string}")
          connection.get(uri, identifier: nil)
        end

        def past_usage(external_customer_id, external_subscription_id, options = {})
          uri = URI(
            "#{client.base_api_url}#{api_resource}/#{external_customer_id}/past_usage",
          )

          connection.get_all(
            options.merge(external_subscription_id: external_subscription_id),
            uri,
          )
        end

        def portal_url(external_customer_id)
          uri = URI(
            "#{client.base_api_url}#{api_resource}/#{external_customer_id}/portal_url",
          )

          response = connection.get(uri, identifier: nil)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct).portal_url
        end

        def checkout_url(external_customer_id)
          uri = URI(
            "#{client.base_api_url}#{api_resource}/#{external_customer_id}/checkout_url",
          )

          response = connection.post({}, uri)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def whitelist_params(params)
          result_hash = {
            external_id: params[:external_id],
            address_line1: params[:address_line1],
            address_line2: params[:address_line2],
            city: params[:city],
            country: params[:country],
            email: params[:email],
            legal_name: params[:legal_name],
            legal_number: params[:legal_number],
            net_payment_term: params[:net_payment_term],
            tax_identification_number: params[:tax_identification_number],
            logo_url: params[:logo_url],
            name: params[:name],
            firstname: params[:firstname],
            lastname: params[:lastname],
            customer_type: params[:customer_type],
            phone: params[:phone],
            state: params[:state],
            url: params[:url],
            zipcode: params[:zipcode],
            currency: params[:currency],
            tax_codes: params[:tax_codes],
            invoice_custom_section_codes: params[:invoice_custom_section_codes],
            timezone: params[:timezone],
            finalize_zero_amount_invoice: params[:finalize_zero_amount_invoice],
            skip_invoice_custom_sections: params[:skip_invoice_custom_sections],
            billing_entity_code: params[:billing_entity_code],
          }

          whitelist_billing_configuration(params[:billing_configuration]).tap do |config|
            result_hash[:billing_configuration] = config unless config.empty?
          end

          whitelist_shipping_address(params[:shipping_address]).tap do |address|
            result_hash[:shipping_address] = address unless address.empty?
          end

          integration_customers = whitelist_integration_customers(params[:integration_customers])
          result_hash[:integration_customers] = integration_customers unless integration_customers.empty?

          metadata = whitelist_metadata(params[:metadata])
          result_hash[:metadata] = metadata unless metadata.empty?

          { root_name => result_hash }
        end

        def whitelist_billing_configuration(billing_params)
          (billing_params || {}).slice(
            :invoice_grace_period,
            :subscription_invoice_issuing_date_anchor,
            :subscription_invoice_issuing_date_adjustment,
            :payment_provider,
            :payment_provider_code,
            :provider_customer_id,
            :sync,
            :sync_with_provider,
            :document_locale,
            :provider_payment_methods,
          )
        end

        def whitelist_shipping_address(address)
          (address || {}).slice(
            :address_line1,
            :address_line2,
            :city,
            :zipcode,
            :state,
            :country,
          )
        end

        def whitelist_integration_customers(integration_customers)
          processed_integration_customers = []

          (integration_customers || []).each do |m|
            result = (m || {})
              .slice(:id,
                     :external_customer_id,
                     :integration_type,
                     :integration_code,
                     :subsidiary_id,
                     :sync_with_provider)

            processed_integration_customers << result unless result.empty?
          end

          processed_integration_customers
        end

        def whitelist_metadata(metadata)
          processed_metadata = []

          (metadata || []).each do |m|
            result = (m || {}).slice(:id, :key, :value, :display_in_invoice)

            processed_metadata << result unless result.empty?
          end

          processed_metadata
        end
      end
    end
  end
end
