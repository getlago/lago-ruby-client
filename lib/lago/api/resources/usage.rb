# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Usage < Base
        def api_resource
          'analytics/usage'
        end

        def root_name
          'usage'
        end
      end
    end
  end
end
