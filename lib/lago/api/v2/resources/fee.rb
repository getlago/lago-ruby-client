# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class Fee < Base
          # GET /fees
          def get_all(options = {})
            request('GET', '/fees', query: options)
          end

          # GET /fees/{lago_id}
          def get(lago_id, options = {})
            request('GET', '/fees/{lago_id}', result_key: 'fee', query: options, lago_id:)
          end

          # PUT /fees/{lago_id}
          def update(params, lago_id)
            request('PUT', '/fees/{lago_id}', params:, body_root: 'fee', result_key: 'fee', lago_id:)
          end

          # PATCH /fees/{lago_id}
          def patch(params, lago_id)
            request('PATCH', '/fees/{lago_id}', params:, body_root: 'fee', result_key: 'fee', lago_id:)
          end

          # DELETE /fees/{lago_id}
          def destroy(lago_id)
            request('DELETE', '/fees/{lago_id}', result_key: 'fee', lago_id:)
          end
        end
      end
    end
  end
end
