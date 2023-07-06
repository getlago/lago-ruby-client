# frozen_string_literal: true

FactoryBot.define do
  factory :update_fee, class: OpenStruct do
    payment_status { 'succeeded' }
  end
end
