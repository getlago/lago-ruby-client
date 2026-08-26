# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      class QuoteVersion < Base
        undef_method :create, :update, :destroy, :get_all

        def api_resource
          'quote_versions'
        end

        def root_name
          'quote_version'
        end

        def approve(quote_version_id, params = {})
          path = "/api/v1/quote_versions/#{quote_version_id}/approve"
          payload = whitelist_approve_params(params)
          response = connection.post(payload, path)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def void(quote_version_id)
          path = "/api/v1/quote_versions/#{quote_version_id}/void"
          response = connection.post({}, path)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def clone(quote_version_id)
          path = "/api/v1/quote_versions/#{quote_version_id}/clone"
          response = connection.post({}, path)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def whitelist_approve_params(params)
          {
            expires_at: params[:expires_at],
          }.compact
        end
      end
    end
  end
end
