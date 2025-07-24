# frozen_string_literal: true

require 'lago/api/resources/base'

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
