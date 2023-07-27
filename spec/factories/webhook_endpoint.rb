# frozen_string_literal: true

FactoryBot.define do
  factory :webhook_endpoint, class: OpenStruct do
    webhook_url { 'https://foo.bar' }
  end
end
