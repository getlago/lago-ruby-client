# frozen_string_literal: true

module Lago
  module Api
    module Resources
      class Plan < Base
        def api_resource
          'plans'
        end

        def root_name
          'plan'
        end

        def whitelist_params(params)
          result_hash = {
            name: params[:name],
            code: params[:code],
            interval: params[:interval],
            description: params[:description],
            amount_cents: params[:amount_cents],
            amount_currency: params[:amount_currency],
            trial_period: params[:trial_period],
            pay_in_advance: params[:pay_in_advance],
            bill_charges_monthly: params[:bill_charges_monthly],
          }.compact

          whitelist_charges(params[:charges]).tap do |charges|
            result_hash[:charges] = charges unless charges.empty?
          end

          { root_name => result_hash }
        end

        def whitelist_charges(charges)
          processed_charges = []

          charges.each do |c|
            result = (c || {}).slice(:id, :billable_metric_id, :charge_model, :properties, :group_properties)

            processed_charges << result unless result.empty?
          end

          processed_charges
        end
      end
    end
  end
end
