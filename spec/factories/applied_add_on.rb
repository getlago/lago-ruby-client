FactoryBot.define do
  factory :applied_add_on, class: OpenStruct do
    customer_id { '5eb02857-a71e-4ea2-bcf9-57d8881110ba' }
    add_on_code { '123' }
    amount_cents { 123 }
    amount_currency { 'EUR'}
  end
end
