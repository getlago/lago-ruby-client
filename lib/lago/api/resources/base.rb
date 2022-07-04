# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Base
        attr_reader :client

        def initialize(client)
          @client = client
        end

        def api_resource
          raise NotImplementedError
        end

        def root_name
          raise NotImplementedError
        end

        def whitelist_params(_params)
          raise NotImplementedError
        end

        def create(params)
          payload = whitelist_params(params)
          response = connection.post(payload)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def update(identifier, params)
          payload = whitelist_params(params)
          response = connection.put(identifier: identifier, body: payload)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def get(identifier)
          response = connection.get(identifier: identifier)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def destroy(identifier)
          response = connection.destroy(identifier: identifier)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def get_all(options = {})
          response = connection.get_all(options)

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        def delete(params)
          response = connection.delete(params)[root_name]

          JSON.parse(response.to_json, object_class: OpenStruct)
        end

        private

        def connection
          uri = URI.join(client.base_api_url, api_resource)

          Lago::Api::Connection.new(client.api_key, uri)
        end
      end
    end
  end
end
