# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class Event < Base
          # GET /events
          def get_all(options = {})
            request('GET', '/events', query: options)
          end

          # POST /events
          def create(params)
            request('POST', '/events', params:, body_root: 'event', result_key: 'event')
          end

          # POST /events/batch
          def create_batch(params)
            request('POST', '/events/batch', params:, body_root: 'events', result_key: 'events')
          end
        end
      end
    end
  end
end
