# frozen_string_literal: true

FactoryBot.define do
  factory :create_payment_request, class: OpenStruct do
    email { "gavin@overdue.test" }
    external_customer_id { "gavin_001" }
    lago_invoice_ids { ["f8e194df-5d90-4382-b146-c881d2c67f28", "a20b1805-d54c-4e57-873d-721cc153035e"] }
  end
end
