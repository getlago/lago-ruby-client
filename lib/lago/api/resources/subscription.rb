# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Subscription < Base
        def api_resource
          'subscriptions'
        end

        def response_root_name
          'subscription'
        end
      end
    end
  end
end
