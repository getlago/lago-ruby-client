# frozen_string_literal: true

FactoryBot.define do
  factory :create_plan_applied_tax, class: OpenStruct do
    tax_code { 'tax_code' }
  end
end
