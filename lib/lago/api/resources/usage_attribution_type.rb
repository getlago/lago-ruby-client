# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      class UsageAttributionType < Base
        def api_resource
          'usage_attribution_types'
        end

        def root_name
          'usage_attribution_type'
        end

        def whitelist_params(params)
          result = {
            code: params[:code],
            name: params[:name],
            attribution_key: params[:attribution_key],
            role: params[:role],
          }.compact

          result[:parent_code] = params[:parent_code] if params.key?(:parent_code)

          { root_name => result }
        end
      end
    end
  end
end
