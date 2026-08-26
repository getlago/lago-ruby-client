# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      class Quote < Base
        undef_method :create, :update, :destroy

        def api_resource
          'quotes'
        end

        def root_name
          'quote'
        end

        def versions(quote_id, options = {})
          path = "/api/v1/quotes/#{quote_id}/versions"
          response = connection.get_all(options, path)

          JSON.parse(response.to_json, object_class: OpenStruct)
        end
      end
    end
  end
end
