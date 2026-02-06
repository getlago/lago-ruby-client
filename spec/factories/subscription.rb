FactoryBot.define do
  factory :subscription, class: OpenStruct do
    lago_id { 'b66b0c31-af01-4f3a-b4eb-017583c37831' }
    lago_customer_id { '5da14b2b-3a7c-4edc-a6df-fad2db464430' }
    external_customer_id { '5eb02857-a71e-4ea2-bcf9-57d8885990ba' }
    external_id { '1232857-a71e-4ea2-bcf9-57d8885990ba' }
    plan_code { 'eartha lynch' }
    plan_amount_cents { 10_000 }
    plan_amount_currency { 'USD' }
    status { 'active' }
    billing_time { 'calendar' }
    started_at { '2022-05-05T12:27:30Z' }
    ending_at { '2022-08-05T00:00:00Z' }
    subscription_at { '2022-05-05T12:27:30Z' }
    terminated_at { nil }
    canceled_at { nil }
    created_at { '2022-05-05T12:27:30Z' }
  end
end
