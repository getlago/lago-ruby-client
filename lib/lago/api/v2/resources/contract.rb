# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class Contract < Base
          # GET /contracts
          def get_all(options = {})
            request('GET', '/contracts', query: options)
          end

          # POST /contracts
          def create(params)
            request('POST', '/contracts', params:, body_root: 'contract', result_key: 'contract')
          end

          # GET /contracts/{external_id}
          def get(external_id, options = {})
            request('GET', '/contracts/{external_id}', result_key: 'contract', query: options, external_id:)
          end

          # PUT /contracts/{external_id}
          def update(params, external_id)
            request(
              'PUT',
              '/contracts/{external_id}',
              params:,
              body_root: 'contract',
              result_key: 'contract',
              external_id:,
            )
          end

          # PATCH /contracts/{external_id}
          def patch(params, external_id)
            request(
              'PATCH',
              '/contracts/{external_id}',
              params:,
              body_root: 'contract',
              result_key: 'contract',
              external_id:,
            )
          end

          # DELETE /contracts/{external_id}
          def destroy(external_id)
            request('DELETE', '/contracts/{external_id}', result_key: 'contract', external_id:)
          end

          # GET /contracts/{external_id}/current_usage
          def current_usage(external_id, options = {})
            request(
              'GET',
              '/contracts/{external_id}/current_usage',
              result_key: 'current_usage',
              query: options,
              external_id:,
            )
          end
        end
      end
    end
  end
end
