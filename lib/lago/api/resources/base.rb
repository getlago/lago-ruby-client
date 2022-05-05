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

        def response_root_name
          raise NotImplementedError
        end

        def create(params)
          response = connection.post(params)[response_root_name]

          OpenStruct.new(response)
        end

        def delete(params)
          response = connection.delete(params)[response_root_name]

          OpenStruct.new(response)
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
