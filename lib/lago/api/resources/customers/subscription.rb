# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      module Customers
        class Subscription < Base
          def api_resource
            "#{base_api_resource}/subscriptions"
          end

          def root_name
            'subscription'
          end
        end
      end
    end
  end
end
