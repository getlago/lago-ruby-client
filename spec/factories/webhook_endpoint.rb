# frozen_string_literal: true

FactoryBot.define do
  factory :webhook_endpoint, class: OpenStruct do
    webhook_url { 'https://foo.bar' }
    signature_algo { 'hmac' }
    name { 'My Webhook Endpoint' }
    event_types { ['customer.created'] }

    trait :standard_webhooks do
      signature_algo { 'standard_webhooks' }
    end
  end
end
