# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      class Nested < Base
        attr_reader :connection

        def initialize(client)
          super(client)
          @connection = Lago::Api::Connection.new(client.api_key, client.base_api_url)
        end

        def whitelist_update_params(params)
          whitelist_params(params)
        end

        def whitelist_create_params(params)
          whitelist_params(params)
        end

        def create(*parent_ids, params)
          path = api_resource(*parent_ids)
          payload = whitelist_create_params(params)
          response = connection.post(payload, path)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def get(*parent_ids, resource_id)
          path = api_resource(*parent_ids)
          response = connection.get(path, identifier: resource_id)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def update(*parent_ids, resource_id, params)
          path = api_resource(*parent_ids)
          payload = whitelist_update_params(params)
          response = connection.put(path, identifier: resource_id, body: payload)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def destroy(*parent_ids, resource_id)
          path = api_resource(*parent_ids)
          response = connection.destroy(path, identifier: resource_id)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def get_all(*parent_ids, **options)
          path = api_resource(*parent_ids)
          response = connection.get_all(options, path)

          JSON.parse(response.to_json, object_class: OpenStruct)
        end
      end
    end
  end
end
