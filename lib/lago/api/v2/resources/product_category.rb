# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class ProductCategory < Base
          # GET /product_categories
          def get_all(options = {})
            request('GET', '/product_categories', query: options)
          end

          # POST /product_categories
          def create(params)
            request(
              'POST',
              '/product_categories',
              params:,
              body_root: 'product_category',
              result_key: 'product_category',
            )
          end

          # GET /product_categories/{code}
          def get(code, options = {})
            request('GET', '/product_categories/{code}', result_key: 'product_category', query: options, code:)
          end

          # PUT /product_categories/{code}
          def update(params, code)
            request(
              'PUT',
              '/product_categories/{code}',
              params:,
              body_root: 'product_category',
              result_key: 'product_category',
              code:,
            )
          end

          # PATCH /product_categories/{code}
          def patch(params, code)
            request(
              'PATCH',
              '/product_categories/{code}',
              params:,
              body_root: 'product_category',
              result_key: 'product_category',
              code:,
            )
          end

          # DELETE /product_categories/{code}
          def destroy(code)
            request('DELETE', '/product_categories/{code}', result_key: 'product_category', code:)
          end
        end
      end
    end
  end
end
