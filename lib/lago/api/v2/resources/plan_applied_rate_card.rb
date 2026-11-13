# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class PlanAppliedRateCard < Base
          # GET /plans/{plan_code}/applied_rate_cards
          def get_all(options = {})
            request('GET', '/plans/{plan_code}/applied_rate_cards', query: options)
          end

          # POST /plans/{plan_code}/applied_rate_cards
          def create(params)
            request(
              'POST',
              '/plans/{plan_code}/applied_rate_cards',
              params:,
              body_root: 'applied_rate_card',
              result_key: 'applied_rate_card',
            )
          end

          # GET /plans/{plan_code}/applied_rate_cards/{code}
          def get(code, options = {})
            request(
              'GET',
              '/plans/{plan_code}/applied_rate_cards/{code}',
              result_key: 'applied_rate_card',
              query: options,
              code:,
            )
          end

          # PUT /plans/{plan_code}/applied_rate_cards/{code}
          def update(params, code)
            request(
              'PUT',
              '/plans/{plan_code}/applied_rate_cards/{code}',
              params:,
              body_root: 'applied_rate_card',
              result_key: 'applied_rate_card',
              code:,
            )
          end

          # PATCH /plans/{plan_code}/applied_rate_cards/{code}
          def patch(params, code)
            request(
              'PATCH',
              '/plans/{plan_code}/applied_rate_cards/{code}',
              params:,
              body_root: 'applied_rate_card',
              result_key: 'applied_rate_card',
              code:,
            )
          end

          # DELETE /plans/{plan_code}/applied_rate_cards/{code}
          def destroy(code)
            request('DELETE', '/plans/{plan_code}/applied_rate_cards/{code}', result_key: 'applied_rate_card', code:)
          end
        end
      end
    end
  end
end
