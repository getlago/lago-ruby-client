# frozen_string_literal: true

require 'lago/api/v2/resources/tax'
require 'lago/api/v2/resources/product_category'
require 'lago/api/v2/resources/product'
require 'lago/api/v2/resources/product_filter'
require 'lago/api/v2/resources/rate_card'
require 'lago/api/v2/resources/rate_card_rate'
require 'lago/api/v2/resources/catalog_plan'
require 'lago/api/v2/resources/plan_applied_rate_card'
require 'lago/api/v2/resources/plan_rate_phase'
require 'lago/api/v2/resources/contract_applied_rate_card'
require 'lago/api/v2/resources/contract_rate_phase'
require 'lago/api/v2/resources/contract'
require 'lago/api/v2/resources/invoice'
require 'lago/api/v2/resources/fee'
require 'lago/api/v2/resources/payment'
require 'lago/api/v2/resources/payment_request'
require 'lago/api/v2/resources/payment_receipt'
require 'lago/api/v2/resources/credit_note'
require 'lago/api/v2/resources/customer'
require 'lago/api/v2/resources/organization'
require 'lago/api/v2/resources/billing_entity'
require 'lago/api/v2/resources/billable_metric'
require 'lago/api/v2/resources/event'
require 'lago/api/v2/resources/activity_log'
require 'lago/api/v2/resources/api_log'
require 'lago/api/v2/resources/security_log'
require 'lago/api/v2/resources/webhook_endpoint'

module Lago
  module Api
    module V2
      OPENAPI_REVISION = 'caa2b1d497d903a8637f148d4c0b41b55df54596'
      BASE_URL = 'https://api.getlago.com/'
      API_PATH = 'api/v2/'

      class Client
        attr_reader :api_key, :api_url, :max_retries, :retry_on_rate_limit, :on_rate_limit_info

        def initialize(api_key: nil, api_url: nil, max_retries: 3, retry_on_rate_limit: true, on_rate_limit_info: nil)
          @api_key = api_key
          @api_url = api_url
          @max_retries = max_retries
          @retry_on_rate_limit = retry_on_rate_limit
          @on_rate_limit_info = on_rate_limit_info
        end

        def base_api_url
          base_url = api_url.nil? ? BASE_URL : api_url
          URI.join(base_url, API_PATH)
        end

        def taxes
          Resources::Tax.new(self)
        end

        def product_categories
          Resources::ProductCategory.new(self)
        end

        def products
          Resources::Product.new(self)
        end

        def product_filters(product_code)
          Resources::ProductFilter.new(self, product_code:)
        end

        def rate_cards
          Resources::RateCard.new(self)
        end

        def rate_card_rates(rate_card_code)
          Resources::RateCardRate.new(self, rate_card_code:)
        end

        def plans
          Resources::CatalogPlan.new(self)
        end

        def plan_applied_rate_cards(plan_code)
          Resources::PlanAppliedRateCard.new(self, plan_code:)
        end

        def plan_rate_phases(plan_code, applied_rate_card_code)
          Resources::PlanRatePhase.new(self, plan_code:, applied_rate_card_code:)
        end

        def contract_applied_rate_cards(contract_external_id)
          Resources::ContractAppliedRateCard.new(self, contract_external_id:)
        end

        def contract_rate_phases(contract_external_id, applied_rate_card_code)
          Resources::ContractRatePhase.new(self, contract_external_id:, applied_rate_card_code:)
        end

        def contracts
          Resources::Contract.new(self)
        end

        def invoices
          Resources::Invoice.new(self)
        end

        def fees
          Resources::Fee.new(self)
        end

        def payments
          Resources::Payment.new(self)
        end

        def payment_requests
          Resources::PaymentRequest.new(self)
        end

        def payment_receipts
          Resources::PaymentReceipt.new(self)
        end

        def credit_notes
          Resources::CreditNote.new(self)
        end

        def customers
          Resources::Customer.new(self)
        end

        def organizations
          Resources::Organization.new(self)
        end

        def billing_entities
          Resources::BillingEntity.new(self)
        end

        def billable_metrics
          Resources::BillableMetric.new(self)
        end

        def events
          Resources::Event.new(self)
        end

        def activity_logs
          Resources::ActivityLog.new(self)
        end

        def api_logs
          Resources::ApiLog.new(self)
        end

        def security_logs
          Resources::SecurityLog.new(self)
        end

        def webhook_endpoints
          Resources::WebhookEndpoint.new(self)
        end

        alias catalog_plans plans
      end
    end
  end
end
