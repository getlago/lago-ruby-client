# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class Tax < Base
          # GET /taxes
          def get_all(options = {})
            request('GET', '/taxes', query: options)
          end

          # POST /taxes
          def create(params)
            request('POST', '/taxes', params:, body_root: 'tax', result_key: 'tax')
          end

          # GET /taxes/{code}
          def get(code, options = {})
            request('GET', '/taxes/{code}', result_key: 'tax', query: options, code:)
          end

          # PUT /taxes/{code}
          def update(params, code)
            request('PUT', '/taxes/{code}', params:, body_root: 'tax', result_key: 'tax', code:)
          end

          # PATCH /taxes/{code}
          def patch(params, code)
            request('PATCH', '/taxes/{code}', params:, body_root: 'tax', result_key: 'tax', code:)
          end

          # DELETE /taxes/{code}
          def destroy(code)
            request('DELETE', '/taxes/{code}', result_key: 'tax', code:)
          end
        end
      end
    end
  end
end
