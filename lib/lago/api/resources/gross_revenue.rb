# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class GrossRevenue < Base
        def api_resource
          'analytics/gross_revenue'
        end

        def root_name
          'gross_revenue'
        end
      end
    end
  end
end
