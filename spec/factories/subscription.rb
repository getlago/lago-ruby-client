FactoryBot.define do
  factory :subscription, class: OpenStruct do
    lago_id { 'b66b0c31-af01-4f3a-b4eb-017583c37831' }
    lago_customer_id { '5da14b2b-3a7c-4edc-a6df-fad2db464430' }
    external_customer_id { '5eb02857-a71e-4ea2-bcf9-57d8885990ba' }
    external_id { '1232857-a71e-4ea2-bcf9-57d8885990ba' }
    plan_code { 'eartha lynch' }
    status { 'active' }
    billing_time { 'calendar' }
    started_at { '2022-05-05T12:27:30Z' }
    subscription_date { '2022-05-05' }
    terminated_at { nil }
    canceled_at { nil }
    created_at { '2022-05-05T12:27:30Z' }
  end
end
