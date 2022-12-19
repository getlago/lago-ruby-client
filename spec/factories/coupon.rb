FactoryBot.define do
  factory :coupon, class: OpenStruct do
    name { 'coupon_name' }
    code { 'coupon_code' }
    expiration_at { '2022-08-08T23:59:59Z' }
    expiration { 'no_expiration' }
    amount_cents { 200 }
    amount_currency { 'EUR' }
    coupon_type { 'fixed_amount' }
    frequency { 'once' }
    reusable { false }
  end
end
