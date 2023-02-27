# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Fee < Base
        def api_resource
          'fees'
        end

        def root_name
          'fee'
        end
      end
    end
  end
end
