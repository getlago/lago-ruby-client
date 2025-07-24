# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      class InvoicedUsage < Base
        def api_resource
          'analytics/invoiced_usage'
        end

        def root_name
          'invoiced_usage'
        end
      end
    end
  end
end
