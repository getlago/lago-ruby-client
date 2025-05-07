# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class ActivityLog < Base
        undef_method :create, :update, :destroy

        def api_resource
          'activity_logs'
        end

        def root_name
          'activity_log'
        end

        def whitelist_params(params)
          {
            root_name => {
              activity_id: params[:activity_id],
            },
          }
        end
      end
    end
  end
end
