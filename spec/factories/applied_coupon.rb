FactoryBot.define do
  factory :applied_coupon, class: OpenStruct do
    external_customer_id { '5eb02857-a71e-4ea2-bcf9-57d8885990ba' }
    coupon_code { '123' }
    amount_cents { 123 }
    amount_currency { 'EUR'}
  end
end
