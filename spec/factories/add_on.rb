FactoryBot.define do
  factory :add_on, class: OpenStruct do
    name { 'name_add_on' }
    code { 'code_add_on' }
    description { 'test description' }
    amount_cents { 200 }
    amount_currency { 'EUR' }
  end
end
