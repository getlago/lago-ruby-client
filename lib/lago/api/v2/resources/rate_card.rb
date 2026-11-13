# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class RateCard < Base
          # GET /rate_cards
          def get_all(options = {})
            request('GET', '/rate_cards', query: options)
          end

          # POST /rate_cards
          def create(params)
            request('POST', '/rate_cards', params:, body_root: 'rate_card', result_key: 'rate_card')
          end

          # GET /rate_cards/{code}
          def get(code, options = {})
            request('GET', '/rate_cards/{code}', result_key: 'rate_card', query: options, code:)
          end

          # PUT /rate_cards/{code}
          def update(params, code)
            request('PUT', '/rate_cards/{code}', params:, body_root: 'rate_card', result_key: 'rate_card', code:)
          end

          # PATCH /rate_cards/{code}
          def patch(params, code)
            request('PATCH', '/rate_cards/{code}', params:, body_root: 'rate_card', result_key: 'rate_card', code:)
          end

          # DELETE /rate_cards/{code}
          def destroy(code)
            request('DELETE', '/rate_cards/{code}', result_key: 'rate_card', code:)
          end
        end
      end
    end
  end
end
