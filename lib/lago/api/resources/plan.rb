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
            invoice_display_name: params[:invoice_display_name],
            code: params[:code],
            interval: params[:interval],
            description: params[:description],
            amount_cents: params[:amount_cents],
            amount_currency: params[:amount_currency],
            trial_period: params[:trial_period],
            pay_in_advance: params[:pay_in_advance],
            bill_charges_monthly: params[:bill_charges_monthly],
            tax_codes: params[:tax_codes],
          }.compact

          whitelist_charges(params[:charges]).tap do |charges|
            result_hash[:charges] = charges unless charges.empty?
          end

          whitelist_minimum_commitment(params[:minimum_commitment]).tap do |minimum_commitment|
            result_hash[:minimum_commitment] = minimum_commitment
          end

          { root_name => result_hash }
        end

        def whitelist_minimum_commitment(minimum_commitment)
          minimum_commitment&.slice(
            :amount_cents,
            :invoice_display_name,
            :tax_codes,
          )
        end

        def whitelist_charges(charges)
          processed_charges = []

          charges&.each do |c|
            result = (c || {}).slice(
              :id,
              :billable_metric_id,
              :charge_model,
              :pay_in_advance,
              :invoiceable,
              :invoice_display_name,
              :min_amount_cents,
              :properties,
              :filters,
              :tax_codes,
            )

            processed_charges << result unless result.empty?
          end

          processed_charges
        end
      end
    end
  end
end
