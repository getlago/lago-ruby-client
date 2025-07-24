# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      class Mrr < Base
        def api_resource
          'analytics/mrr'
        end

        def root_name
          'mrr'
        end
      end
    end
  end
end
