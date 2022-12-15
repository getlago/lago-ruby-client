FactoryBot.define do
  factory :coupon, class: OpenStruct do
    name { 'coupon_name' }
    code { 'coupon_code' }
    expiration_date { '2022-08-08' }
    expiration { 'no_expiration' }
    amount_cents { 200 }
    amount_currency { 'EUR' }
    coupon_type { 'fixed_amount' }
    frequency { 'once' }
    reusable { false }
  end
end
