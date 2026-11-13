# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class BillingEntity < Base
          # GET /billing_entities
          def get_all(options = {})
            request('GET', '/billing_entities', query: options)
          end

          # POST /billing_entities
          def create(params)
            request('POST', '/billing_entities', params:, body_root: 'billing_entity', result_key: 'billing_entity')
          end

          # GET /billing_entities/{code}
          def get(code, options = {})
            request('GET', '/billing_entities/{code}', result_key: 'billing_entity', query: options, code:)
          end

          # PUT /billing_entities/{code}
          def update(params, code)
            request(
              'PUT',
              '/billing_entities/{code}',
              params:,
              body_root: 'billing_entity',
              result_key: 'billing_entity',
              code:,
            )
          end

          # PATCH /billing_entities/{code}
          def patch(params, code)
            request(
              'PATCH',
              '/billing_entities/{code}',
              params:,
              body_root: 'billing_entity',
              result_key: 'billing_entity',
              code:,
            )
          end
        end
      end
    end
  end
end
