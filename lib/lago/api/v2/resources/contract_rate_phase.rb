# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class ContractRatePhase < Base
          # GET /contracts/{contract_external_id}/applied_rate_cards/{applied_rate_card_code}/rate_phases
          def get_all(options = {})
            request(
              'GET',
              '/contracts/{contract_external_id}/applied_rate_cards/{applied_rate_card_code}/rate_phases',
              query: options,
            )
          end

          # POST /contracts/{contract_external_id}/applied_rate_cards/{applied_rate_card_code}/rate_phases
          def create(params)
            request(
              'POST',
              '/contracts/{contract_external_id}/applied_rate_cards/{applied_rate_card_code}/rate_phases',
              params:,
              body_root: 'rate_phase',
              result_key: 'rate_phase',
            )
          end

          # PUT /contracts/{contract_external_id}/applied_rate_cards/{applied_rate_card_code}/rate_phases/{code}
          def update(params, code)
            request(
              'PUT',
              '/contracts/{contract_external_id}/applied_rate_cards/{applied_rate_card_code}/rate_phases/{code}',
              params:,
              body_root: 'rate_phase',
              result_key: 'rate_phase',
              code:,
            )
          end

          # PATCH /contracts/{contract_external_id}/applied_rate_cards/{applied_rate_card_code}/rate_phases/{code}
          def patch(params, code)
            request(
              'PATCH',
              '/contracts/{contract_external_id}/applied_rate_cards/{applied_rate_card_code}/rate_phases/{code}',
              params:,
              body_root: 'rate_phase',
              result_key: 'rate_phase',
              code:,
            )
          end

          # DELETE /contracts/{contract_external_id}/applied_rate_cards/{applied_rate_card_code}/rate_phases/{code}
          def destroy(code)
            request(
              'DELETE',
              '/contracts/{contract_external_id}/applied_rate_cards/{applied_rate_card_code}/rate_phases/{code}',
              result_key: 'rate_phase',
              code:,
            )
          end
        end
      end
    end
  end
end
