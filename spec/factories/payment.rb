# frozen_string_literal: true

FactoryBot.define do
  factory :create_payment, class: OpenStruct do
    invoice_id { 'ed267c66-8170-4d23-83e8-6d6e4fc735ef'}
    amount_cents { 100 }
    reference { 'the reference'}
    paid_at { '2024-06-30T10:59:51Z' }
  end
end
