# frozen_string_literal: true

FactoryBot.define do
  factory :payment_method, class: OpenStruct do
    lago_id { 'b7ab2926-1de8-4428-9bcd-779314ac129b' }
    is_default { false }
    payment_provider_code { 'stripe' }
    payment_provider_name { 'Stripe' }
    payment_provider_type { 'card' }
    provider_method_id { 'pm_123456' }
    created_at { '2024-06-30T10:59:51Z' }
  end
end
