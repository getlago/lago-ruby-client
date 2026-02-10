# frozen_string_literal: true

require 'lago/api/resources/base'
require 'lago/api/resources/activity_log'
require 'lago/api/resources/add_on'
require 'lago/api/resources/api_log'
require 'lago/api/resources/applied_coupon'
require 'lago/api/resources/billable_metric'
require 'lago/api/resources/billing_entity'
require 'lago/api/resources/coupon'
require 'lago/api/resources/credit_note'
require 'lago/api/resources/customer'
require 'lago/api/resources/customers/base'
require 'lago/api/resources/customers/applied_coupon'
require 'lago/api/resources/customers/credit_note'
require 'lago/api/resources/customers/invoice'
require 'lago/api/resources/customers/payment'
require 'lago/api/resources/customers/payment_request'
require 'lago/api/resources/customers/subscription'
require 'lago/api/resources/customers/wallet'
require 'lago/api/resources/customers/wallets'
require 'lago/api/resources/customers/wallets/base'
require 'lago/api/resources/customers/wallets/metadata'
require 'lago/api/resources/event'
require 'lago/api/resources/feature'
require 'lago/api/resources/fee'
require 'lago/api/resources/gross_revenue'
require 'lago/api/resources/invoice'
require 'lago/api/resources/invoice_collection'
require 'lago/api/resources/invoiced_usage'
require 'lago/api/resources/mrr'
require 'lago/api/resources/organization'
require 'lago/api/resources/overdue_balance'
require 'lago/api/resources/payment'
require 'lago/api/resources/payment_receipt'
require 'lago/api/resources/payment_request'
require 'lago/api/resources/plan'
require 'lago/api/resources/subscription'
require 'lago/api/resources/tax'
require 'lago/api/resources/usage'
require 'lago/api/resources/wallet'
require 'lago/api/resources/wallet_transaction'
require 'lago/api/resources/webhook'
require 'lago/api/resources/webhook_endpoint'

module Lago
  module Api
    BASE_URL = 'https://api.getlago.com/'
    BASE_INGEST_URL = 'https://ingest.getlago.com/'
    API_PATH = 'api/v1/'

    class Client
      attr_reader :api_key, :api_url, :use_ingest_service, :ingest_api_url

      def initialize(api_key: nil, api_url: nil, use_ingest_service: false, ingest_api_url: nil)
        @api_key = api_key
        @api_url = api_url
        @use_ingest_service = use_ingest_service
        @ingest_api_url = ingest_api_url
      end

      def base_api_url
        base_url = api_url.nil? ? Lago::Api::BASE_URL : api_url

        URI.join(base_url, Lago::Api::API_PATH)
      end

      def base_ingest_api_url
        return base_api_url unless use_ingest_service

        ingest_url = ingest_api_url.nil? ? Lago::Api::BASE_INGEST_URL : ingest_api_url
        URI.join(ingest_url, Lago::Api::API_PATH)
      end

      # Resources
      def activity_logs
        Resources::ActivityLog.new(self)
      end

      def add_ons
        Resources::AddOn.new(self)
      end

      def api_logs
        Resources::ApiLog.new(self)
      end

      def applied_coupons
        Resources::AppliedCoupon.new(self)
      end

      def billable_metrics
        Resources::BillableMetric.new(self)
      end

      def billing_entities
        Resources::BillingEntity.new(self)
      end

      def coupons
        Resources::Coupon.new(self)
      end

      def credit_notes
        Resources::CreditNote.new(self)
      end

      def customers
        Resources::Customer.new(self)
      end

      def customer_applied_coupons(resource_id)
        Resources::Customers::AppliedCoupon.new(self, resource_id)
      end

      def customer_credit_notes(resource_id)
        Resources::Customers::CreditNote.new(self, resource_id)
      end

      def customer_invoices(resource_id)
        Resources::Customers::Invoice.new(self, resource_id)
      end

      def customer_payments(resource_id)
        Resources::Customers::Payment.new(self, resource_id)
      end

      def customer_payment_requests(resource_id)
        Resources::Customers::PaymentRequest.new(self, resource_id)
      end

      def customer_subscriptions(resource_id)
        Resources::Customers::Subscription.new(self, resource_id)
      end

      def customer_wallets(resource_id)
        Resources::Customers::Wallet.new(self, resource_id)
      end

      def events
        Resources::Event.new(self)
      end

      def features
        Resources::Feature.new(self)
      end

      def fees
        Resources::Fee.new(self)
      end

      def gross_revenues
        Resources::GrossRevenue.new(self)
      end

      def invoice_collections
        Resources::InvoiceCollection.new(self)
      end

      def invoiced_usages
        Resources::InvoicedUsage.new(self)
      end

      def invoices
        Resources::Invoice.new(self)
      end

      def mrrs
        Resources::Mrr.new(self)
      end

      def organizations
        Resources::Organization.new(self)
      end

      def overdue_balances
        Resources::OverdueBalance.new(self)
      end

      def payment_receipts
        Resources::PaymentReceipt.new(self)
      end

      def payment_requests
        Resources::PaymentRequest.new(self)
      end

      def payments
        Resources::Payment.new(self)
      end

      def plans
        Resources::Plan.new(self)
      end

      def subscriptions
        Resources::Subscription.new(self)
      end

      def taxes
        Resources::Tax.new(self)
      end

      def wallet_transactions
        Resources::WalletTransaction.new(self)
      end

      def wallets
        Resources::Wallet.new(self)
      end

      def webhook_endpoints
        Resources::WebhookEndpoint.new(self)
      end

      def webhooks
        Resources::Webhook.new(self)
      end
    end
  end
end
