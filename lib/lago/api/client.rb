# frozen_string_literal: true

module Lago
  module Api
    BASE_URL = 'https://api.getlago.com/'.freeze
    API_PATH = 'api/v1/'.freeze

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

      def subscriptions
        Lago::Api::Resources::Subscription.new(self)
      end

      def events
        Lago::Api::Resources::Event.new(self)
      end
    end
  end
end
