# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class Product < Base
          # GET /products
          def get_all(options = {})
            request('GET', '/products', query: options)
          end

          # POST /products
          def create(params)
            request('POST', '/products', params:, body_root: 'product', result_key: 'product')
          end

          # GET /products/{code}
          def get(code, options = {})
            request('GET', '/products/{code}', result_key: 'product', query: options, code:)
          end

          # PUT /products/{code}
          def update(params, code)
            request('PUT', '/products/{code}', params:, body_root: 'product', result_key: 'product', code:)
          end

          # PATCH /products/{code}
          def patch(params, code)
            request('PATCH', '/products/{code}', params:, body_root: 'product', result_key: 'product', code:)
          end

          # DELETE /products/{code}
          def destroy(code)
            request('DELETE', '/products/{code}', result_key: 'product', code:)
          end
        end
      end
    end
  end
end
