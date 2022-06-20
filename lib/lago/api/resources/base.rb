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

          OpenStruct.new(response)
        end

        def update(params)
          payload = whitelist_params(params)
          response = connection.put(lago_id: params[:lago_id], body: payload)[root_name]

          OpenStruct.new(response)
        end

        def delete(params)
          response = connection.delete(params)[root_name]

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
