# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class PlanRatePhase < Base
          # GET /plans/{plan_code}/applied_rate_cards/{applied_rate_card_code}/rate_phases
          def get_all(options = {})
            request('GET', '/plans/{plan_code}/applied_rate_cards/{applied_rate_card_code}/rate_phases', query: options)
          end

          # POST /plans/{plan_code}/applied_rate_cards/{applied_rate_card_code}/rate_phases
          def create(params)
            request(
              'POST',
              '/plans/{plan_code}/applied_rate_cards/{applied_rate_card_code}/rate_phases',
              params:,
              body_root: 'rate_phase',
              result_key: 'rate_phase',
            )
          end

          # PUT /plans/{plan_code}/applied_rate_cards/{applied_rate_card_code}/rate_phases/{code}
          def update(params, code)
            request(
              'PUT',
              '/plans/{plan_code}/applied_rate_cards/{applied_rate_card_code}/rate_phases/{code}',
              params:,
              body_root: 'rate_phase',
              result_key: 'rate_phase',
              code:,
            )
          end

          # PATCH /plans/{plan_code}/applied_rate_cards/{applied_rate_card_code}/rate_phases/{code}
          def patch(params, code)
            request(
              'PATCH',
              '/plans/{plan_code}/applied_rate_cards/{applied_rate_card_code}/rate_phases/{code}',
              params:,
              body_root: 'rate_phase',
              result_key: 'rate_phase',
              code:,
            )
          end

          # DELETE /plans/{plan_code}/applied_rate_cards/{applied_rate_card_code}/rate_phases/{code}
          def destroy(code)
            request(
              'DELETE',
              '/plans/{plan_code}/applied_rate_cards/{applied_rate_card_code}/rate_phases/{code}',
              result_key: 'rate_phase',
              code:,
            )
          end
        end
      end
    end
  end
end
