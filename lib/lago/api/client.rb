# frozen_string_literal: true

module Lago
  module Api
    BASE_URL = 'https://api.getlago.com/'
    API_PATH = 'api/v1/'

    class Client
      attr_reader :api_key, :api_url

      def initialize(api_key: nil, api_url: nil)
        @api_key = api_key
        @api_url = api_url
      end

      def base_api_url
        base_url = api_url.nil? ? Lago::Api::BASE_URL : api_url

        URI.join(base_url, Lago::Api::API_PATH)
      end

      def customers
        Lago::Api::Resources::Customer.new(self)
      end

      def invoices
        Lago::Api::Resources::Invoice.new(self)
      end

      def subscriptions
        Lago::Api::Resources::Subscription.new(self)
      end

      def events
        Lago::Api::Resources::Event.new(self)
      end

      def groups
        Lago::Api::Resources::Group.new(self)
      end

      def applied_coupons
        Lago::Api::Resources::AppliedCoupon.new(self)
      end

      def applied_add_ons
        Lago::Api::Resources::AppliedAddOn.new(self)
      end

      def billable_metrics
        Lago::Api::Resources::BillableMetric.new(self)
      end

      def credit_notes
        Lago::Api::Resources::CreditNote.new(self)
      end

      def plans
        Lago::Api::Resources::Plan.new(self)
      end

      def coupons
        Lago::Api::Resources::Coupon.new(self)
      end

      def add_ons
        Lago::Api::Resources::AddOn.new(self)
      end

      def organizations
        Lago::Api::Resources::Organization.new(self)
      end

      def wallets
        Lago::Api::Resources::Wallet.new(self)
      end

      def wallet_transactions
        Lago::Api::Resources::WalletTransaction.new(self)
      end

      def webhooks
        Lago::Api::Resources::Webhook.new(self)
      end
    end
  end
end
