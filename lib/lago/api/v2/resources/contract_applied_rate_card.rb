# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class ContractAppliedRateCard < Base
          # GET /contracts/{contract_external_id}/applied_rate_cards
          def get_all(options = {})
            request('GET', '/contracts/{contract_external_id}/applied_rate_cards', query: options)
          end

          # POST /contracts/{contract_external_id}/applied_rate_cards
          def create(params)
            request(
              'POST',
              '/contracts/{contract_external_id}/applied_rate_cards',
              params:,
              body_root: 'applied_rate_card',
              result_key: 'applied_rate_card',
            )
          end

          # GET /contracts/{contract_external_id}/applied_rate_cards/{code}
          def get(code, options = {})
            request(
              'GET',
              '/contracts/{contract_external_id}/applied_rate_cards/{code}',
              result_key: 'applied_rate_card',
              query: options,
              code:,
            )
          end

          # PUT /contracts/{contract_external_id}/applied_rate_cards/{code}
          def update(params, code)
            request(
              'PUT',
              '/contracts/{contract_external_id}/applied_rate_cards/{code}',
              params:,
              body_root: 'applied_rate_card',
              result_key: 'applied_rate_card',
              code:,
            )
          end

          # PATCH /contracts/{contract_external_id}/applied_rate_cards/{code}
          def patch(params, code)
            request(
              'PATCH',
              '/contracts/{contract_external_id}/applied_rate_cards/{code}',
              params:,
              body_root: 'applied_rate_card',
              result_key: 'applied_rate_card',
              code:,
            )
          end

          # DELETE /contracts/{contract_external_id}/applied_rate_cards/{code}
          def destroy(code)
            request(
              'DELETE',
              '/contracts/{contract_external_id}/applied_rate_cards/{code}',
              result_key: 'applied_rate_card',
              code:,
            )
          end
        end
      end
    end
  end
end
