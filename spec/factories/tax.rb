FactoryBot.define do
  factory :tax, class: OpenStruct do
    name { 'name_rate' }
    code { 'code_rate' }
    rate { 15.0 }
    description { 'description_rate' }
    applied_to_organization { false }
  end
end
