# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class Customer < Base
          # GET /customers
          def get_all(options = {})
            request('GET', '/customers', query: options)
          end

          # POST /customers
          def create(params)
            request('POST', '/customers', params:, body_root: 'customer', result_key: 'customer')
          end

          # GET /customers/{external_id}
          def get(external_id, options = {})
            request('GET', '/customers/{external_id}', result_key: 'customer', query: options, external_id:)
          end

          # PUT /customers/{external_id}
          def update(params, external_id)
            request(
              'PUT',
              '/customers/{external_id}',
              params:,
              body_root: 'customer',
              result_key: 'customer',
              external_id:,
            )
          end

          # PATCH /customers/{external_id}
          def patch(params, external_id)
            request(
              'PATCH',
              '/customers/{external_id}',
              params:,
              body_root: 'customer',
              result_key: 'customer',
              external_id:,
            )
          end

          # DELETE /customers/{external_id}
          def destroy(external_id)
            request('DELETE', '/customers/{external_id}', result_key: 'customer', external_id:)
          end

          # POST /customers/{customer_external_id}/checkout_url
          def checkout_url(customer_external_id)
            request(
              'POST',
              '/customers/{customer_external_id}/checkout_url',
              result_key: 'checkout_url',
              customer_external_id:,
            )
          end

          # GET /customers/{customer_external_id}/invoices
          def invoices(customer_external_id, options = {})
            request('GET', '/customers/{customer_external_id}/invoices', query: options, customer_external_id:)
          end

          # GET /customers/{customer_external_id}/credit_notes
          def credit_notes(customer_external_id, options = {})
            request('GET', '/customers/{customer_external_id}/credit_notes', query: options, customer_external_id:)
          end

          # GET /customers/{customer_external_id}/payments
          def payments(customer_external_id, options = {})
            request('GET', '/customers/{customer_external_id}/payments', query: options, customer_external_id:)
          end

          # GET /customers/{customer_external_id}/payment_requests
          def payment_requests(customer_external_id, options = {})
            request('GET', '/customers/{customer_external_id}/payment_requests', query: options, customer_external_id:)
          end

          # GET /customers/{customer_external_id}/payment_methods
          def payment_methods(customer_external_id, options = {})
            request('GET', '/customers/{customer_external_id}/payment_methods', query: options, customer_external_id:)
          end

          # DELETE /customers/{customer_external_id}/payment_methods/{lago_id}
          def destroy_payment_method(customer_external_id, lago_id)
            request(
              'DELETE',
              '/customers/{customer_external_id}/payment_methods/{lago_id}',
              result_key: 'payment_method',
              customer_external_id:,
              lago_id:,
            )
          end

          # PUT /customers/{customer_external_id}/payment_methods/{lago_id}/set_as_default
          def set_default_payment_method(customer_external_id, lago_id)
            request(
              'PUT',
              '/customers/{customer_external_id}/payment_methods/{lago_id}/set_as_default',
              result_key: 'payment_method',
              customer_external_id:,
              lago_id:,
            )
          end
        end
      end
    end
  end
end
