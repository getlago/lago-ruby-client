FactoryBot.define do
  factory :coupon, class: OpenStruct do
    name { 'coupon_name' }
    code { 'coupon_code' }
    expiration_duration { 10 }
    expiration { 'no_expiration' }
    amount_cents { 200 }
    amount_currency { 'EUR' }
  end
end
