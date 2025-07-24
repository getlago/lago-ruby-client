# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      class ApiLog < Base
        undef_method :create, :update, :destroy

        def api_resource
          'api_logs'
        end

        def root_name
          'api_log'
        end

        def whitelist_params(params)
          {
            root_name => {
              api_log: params[:request_id],
            },
          }
        end
      end
    end
  end
end
