FactoryBot.define do
  factory :tax_rate, class: OpenStruct do
    name { 'name_tax_rate' }
    code { 'code_tax_rate' }
    value { 15.0 }
    description { 'description_tax_rate' }
  end
end
