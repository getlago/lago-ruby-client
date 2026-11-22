# frozen_string_literal: true

require 'lago/api/v2/resources/base'

module Lago
  module Api
    module V2
      module Resources
        class Organization < Base
          # GET /organizations
          def get(options = {})
            request('GET', '/organizations', result_key: 'organization', query: options)
          end

          # PUT /organizations
          def update(params)
            request('PUT', '/organizations', params:, body_root: 'organization', result_key: 'organization')
          end
        end
      end
    end
  end
end
