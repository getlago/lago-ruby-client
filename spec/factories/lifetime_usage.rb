# frozen_string_literal: true

FactoryBot.define do
  factory :update_lifetime_usage, class: OpenStruct do
    external_historical_usage_amount_cents { 100 }
  end
end
