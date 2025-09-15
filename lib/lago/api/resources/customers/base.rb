# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      module Customers
        class Base < Lago::Api::Resources::Base
          def initialize(client, resource_id)
            super(client)
            @resource_id = resource_id
          end

          def base_api_resource
            "customers/#{resource_id}"
          end

          def create(params)
            raise NotImplementedError
          end

          def update(params, identifier = nil)
            raise NotImplementedError
          end

          def get(identifier)
            raise NotImplementedError
          end

          def destroy(identifier, options: nil)
            raise NotImplementedError
          end

          private

          attr_reader :resource_id
        end
      end
    end
  end
end
