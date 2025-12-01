# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Feature < Base
        def api_resource
          'features'
        end

        def root_name
          'feature'
        end

        def whitelist_params(params)
          result_hash = {
            code: params[:code],
            name: params[:name],
            description: params[:description],
            privileges: whitelist_privileges_params(params[:privileges]),
          }.compact

          { root_name => result_hash }
        end

        def whitelist_privileges_params(privileges)
          privileges&.map do |privilege|
            {
              code: privilege[:code],
              name: privilege[:name],
              value_type: privilege[:value_type]
            }.tap do |h|
              h[:config] = {
                select_options: privilege[:config][:select_options],
              } if privilege[:config]
            end
          end
        end
      end
    end
  end
end
