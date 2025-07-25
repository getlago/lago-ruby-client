# frozen_string_literal: true

FactoryBot.define do
  factory :feature, class: OpenStruct do
    code { 'seats' }
    name { 'Seats' }
    description { 'Nb users' }
    privileges do
      [
        { code: 'max', name: 'Max', value_type: 'integer' },
      ]
    end
  end
end
