# frozen_string_literal: true

FactoryBot.define do
  factory :create_tax, class: OpenStruct do
    name { 'name_rate' }
    code { 'code_rate' }
    rate { 15.0 }
    description { 'description_rate' }
    applied_to_organization { false }
  end
end
