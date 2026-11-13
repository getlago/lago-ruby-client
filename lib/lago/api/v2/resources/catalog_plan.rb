# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class CatalogPlan < Base
          # GET /plans
          def get_all(options = {})
            request('GET', '/plans', query: options)
          end

          # POST /plans
          def create(params)
            request('POST', '/plans', params:, body_root: 'plan', result_key: 'plan')
          end

          # GET /plans/{code}
          def get(code, options = {})
            request('GET', '/plans/{code}', result_key: 'plan', query: options, code:)
          end

          # PUT /plans/{code}
          def update(params, code)
            request('PUT', '/plans/{code}', params:, body_root: 'plan', result_key: 'plan', code:)
          end

          # PATCH /plans/{code}
          def patch(params, code)
            request('PATCH', '/plans/{code}', params:, body_root: 'plan', result_key: 'plan', code:)
          end
        end
      end
    end
  end
end
