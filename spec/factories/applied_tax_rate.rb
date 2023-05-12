FactoryBot.define do
  factory :applied_tax_rate, class: OpenStruct do
    external_customer_id { '5eb02857-a71e-4ea2-bcf9-57d8881110ba' }
    tax_rate_code { '123' }
  end
end
