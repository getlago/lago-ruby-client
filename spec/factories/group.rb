# frozen_string_literal: true

FactoryBot.define do
  factory :group, class: OpenStruct do
    lago_id { 'lago_internal_id' }
    key { 'aws' }
    value { 'europe' }
  end
end
