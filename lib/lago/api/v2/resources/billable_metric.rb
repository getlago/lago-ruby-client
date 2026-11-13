# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class BillableMetric < Base
          # GET /billable_metrics
          def get_all(options = {})
            request('GET', '/billable_metrics', query: options)
          end

          # POST /billable_metrics
          def create(params)
            request('POST', '/billable_metrics', params:, body_root: 'billable_metric', result_key: 'billable_metric')
          end

          # GET /billable_metrics/{code}
          def get(code, options = {})
            request('GET', '/billable_metrics/{code}', result_key: 'billable_metric', query: options, code:)
          end

          # PUT /billable_metrics/{code}
          def update(params, code)
            request(
              'PUT',
              '/billable_metrics/{code}',
              params:,
              body_root: 'billable_metric',
              result_key: 'billable_metric',
              code:,
            )
          end

          # PATCH /billable_metrics/{code}
          def patch(params, code)
            request(
              'PATCH',
              '/billable_metrics/{code}',
              params:,
              body_root: 'billable_metric',
              result_key: 'billable_metric',
              code:,
            )
          end

          # DELETE /billable_metrics/{code}
          def destroy(code)
            request('DELETE', '/billable_metrics/{code}', result_key: 'billable_metric', code:)
          end
        end
      end
    end
  end
end
