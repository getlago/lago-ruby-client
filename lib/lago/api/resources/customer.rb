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

        def current_usage(external_customer_id, external_subscription_id)
          uri = URI(
            "#{client.base_api_url}#{api_resource}/#{external_customer_id}" \
              "/current_usage?external_subscription_id=#{external_subscription_id}",
          )
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

          response = connection.post(uri)[root_name]

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
            phone: params[:phone],
            state: params[:state],
            url: params[:url],
            zipcode: params[:zipcode],
            currency: params[:currency],
            tax_codes: params[:tax_codes],
            timezone: params[:timezone],
          }

          whitelist_billing_configuration(params[:billing_configuration]).tap do |config|
            result_hash[:billing_configuration] = config unless config.empty?
          end

          metadata = whitelist_metadata(params[:metadata])
          result_hash[:metadata] = metadata unless metadata.empty?

          { root_name => result_hash }
        end

        def whitelist_billing_configuration(billing_params)
          (billing_params || {}).slice(
            :invoice_grace_period,
            :payment_provider,
            :provider_customer_id,
            :sync,
            :sync_with_provider,
            :document_locale,
            :provider_payment_methods,
          )
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
