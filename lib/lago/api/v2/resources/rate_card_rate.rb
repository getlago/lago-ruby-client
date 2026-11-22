# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class RateCardRate < Base
          # GET /rate_cards/{rate_card_code}/rates
          def get_all(options = {})
            request('GET', '/rate_cards/{rate_card_code}/rates', query: options)
          end

          # POST /rate_cards/{rate_card_code}/rates
          def create(params)
            request('POST', '/rate_cards/{rate_card_code}/rates', params:, body_root: 'rate', result_key: 'rate')
          end

          # GET /rate_cards/{rate_card_code}/rates/{code}
          def get(code, options = {})
            request('GET', '/rate_cards/{rate_card_code}/rates/{code}', result_key: 'rate', query: options, code:)
          end

          # PUT /rate_cards/{rate_card_code}/rates/{code}
          def update(params, code)
            request(
              'PUT',
              '/rate_cards/{rate_card_code}/rates/{code}',
              params:,
              body_root: 'rate',
              result_key: 'rate',
              code:,
            )
          end

          # PATCH /rate_cards/{rate_card_code}/rates/{code}
          def patch(params, code)
            request(
              'PATCH',
              '/rate_cards/{rate_card_code}/rates/{code}',
              params:,
              body_root: 'rate',
              result_key: 'rate',
              code:,
            )
          end

          # DELETE /rate_cards/{rate_card_code}/rates/{code}
          def destroy(code)
            request('DELETE', '/rate_cards/{rate_card_code}/rates/{code}', result_key: 'rate', code:)
          end
        end
      end
    end
  end
end
