# frozen_string_literal: true

FactoryBot.define do
  factory :credit_note, class: OpenStruct do
    lago_id { 'lago_internal_id' }
    sequential_id { 15 }
    number { 'LAG3-CN5' }
    lago_invoice_id { 'lago_invoice_internal_id' }
    invoice_number { 'LAG3' }
    credit_status { 'available' }
    refund_status { 'pending' }
    reason { 'other' }
    total_amount_cents { 120 }
    total_amount_currency { 'EUR' }
    credit_amount_cents { 80 }
    credit_amount_currency { 'EUR' }
    balance_amount_cents { 100 }
    balance_amount_currency { 'EUR' }
    refund_amount_cents { 20 }
    refund_amount_currency { 'EUR' }
    vat_amount_cents { 20 }
    vat_amount_currency { 'EUR' }
    sub_total_vat_excluded_amount_cents { 100 }
    sub_total_vat_excluded_amount_currency { 'EUR' }
    created_at { '2022-10-04 14:51:00' }
    updated_at { '2022-10-04 14:51:00' }
  end
end
