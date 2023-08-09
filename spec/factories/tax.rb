# frozen_string_literal: true

FactoryBot.define do
  factory :create_tax, class: OpenStruct do
    name { 'name_tax' }
    code { 'code_tax' }
    rate { 15.0 }
    description { 'description_tax' }
    applied_to_organization { false }
  end
end
