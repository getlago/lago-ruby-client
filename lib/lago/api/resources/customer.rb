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
            "#{client.base_api_url}#{api_resource}/#{external_customer_id}/current_usage?external_subscription_id=#{external_subscription_id}"
          )
          connection.get(uri, identifier: nil)
        end

        def portal_url(external_customer_id)
          uri = URI(
            "#{client.base_api_url}#{api_resource}/#{external_customer_id}/portal_url"
          )

          response = connection.get(uri, identifier: nil)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct).portal_url
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
            logo_url: params[:logo_url],
            name: params[:name],
            phone: params[:phone],
            state: params[:state],
            url: params[:url],
            zipcode: params[:zipcode],
            currency: params[:currency],
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
            :vat_rate,
            :document_locale,
          )
        end

        def whitelist_metadata(metadata)
          processed_metadata = []

          metadata.each do |m|
            result = (m || {}).slice(:id, :key, :value, :display_in_invoice)

            processed_metadata << result unless result.empty?
          end

          processed_metadata
        end
      end
    end
  end
end
