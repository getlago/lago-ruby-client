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

          { root_name => result_hash }
        end

        def whitelist_billing_configuration(billing_params)
          (billing_params || {}).slice(
            :payment_provider,
            :provider_customer_id,
            :sync,
            :sync_with_provider,
            :vat_rate,
          )
        end
      end
    end
  end
end
