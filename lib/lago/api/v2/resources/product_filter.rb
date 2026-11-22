# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class ProductFilter < Base
          # GET /products/{product_code}/filters
          def get_all(options = {})
            request('GET', '/products/{product_code}/filters', query: options)
          end

          # POST /products/{product_code}/filters
          def create(params)
            request('POST', '/products/{product_code}/filters', params:, body_root: 'filter', result_key: 'filter')
          end

          # GET /products/{product_code}/filters/{code}
          def get(code, options = {})
            request('GET', '/products/{product_code}/filters/{code}', result_key: 'filter', query: options, code:)
          end

          # PUT /products/{product_code}/filters/{code}
          def update(params, code)
            request(
              'PUT',
              '/products/{product_code}/filters/{code}',
              params:,
              body_root: 'filter',
              result_key: 'filter',
              code:,
            )
          end

          # PATCH /products/{product_code}/filters/{code}
          def patch(params, code)
            request(
              'PATCH',
              '/products/{product_code}/filters/{code}',
              params:,
              body_root: 'filter',
              result_key: 'filter',
              code:,
            )
          end

          # DELETE /products/{product_code}/filters/{code}
          def destroy(code)
            request('DELETE', '/products/{product_code}/filters/{code}', result_key: 'filter', code:)
          end
        end
      end
    end
  end
end
