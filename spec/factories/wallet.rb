FactoryBot.define do
  factory :wallet, class: OpenStruct do
    name { 'wallet name' }
    external_customer_id { '12345' }
    expiration_at { '2022-07-07T23:59:59Z' }
    rate_amount { '1' }
    paid_credits { '100' }
    granted_credits { '100' }
  end
end
