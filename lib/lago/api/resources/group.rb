# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Group < Base
        def api_resource
          'groups'
        end

        def root_name
          'group'
        end

        def get_all(code, options = {})
          path = "/api/v1/billable_metrics/#{code}/groups"
          response = connection.get_all(options, path)

          JSON.parse(response.to_json, object_class: OpenStruct)
        end
      end
    end
  end
end
