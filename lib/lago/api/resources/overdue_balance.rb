# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class OverdueBalance < Base
        def api_resource
          'analytics/overdue_balance'
        end

        def root_name
          'overdue_balance'
        end
      end
    end
  end
end
