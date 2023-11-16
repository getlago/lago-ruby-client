FactoryBot.define do
  factory :wallet, class: OpenStruct do
    name { 'wallet name' }
    external_customer_id { '12345' }
    expiration_at { '2022-07-07T23:59:59Z' }
    rate_amount { '1' }
    paid_credits { '100' }
    granted_credits { '100' }
    recurring_transaction_rules do
      [
        {
          rule_type: 'interval',
          interval: 'monthly',
          paid_credits: '105',
          granted_credits: '105',
        },
      ]
    end
  end
end
