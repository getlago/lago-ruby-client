# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Event < Base
        def api_resource
          'events'
        end

        def create(params)
          connection.post(params)
        end
      end
    end
  end
end
