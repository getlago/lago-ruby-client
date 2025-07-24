# frozen_string_literal: true

require 'lago/api/resources/base'

module Lago
  module Api
    module Resources
      class Payment < Base
        def api_resource
          'payments'
        end

        def root_name
          'payment'
        end

        def whitelist_params(params)
          result_hash = {
            invoice_id: params[:invoice_id],
            amount_cents: params[:amount_cents],
            reference: params[:reference],
            paid_at: params[:paid_at]
          }.compact

          { root_name => result_hash }
        end
      end
    end
  end
end
