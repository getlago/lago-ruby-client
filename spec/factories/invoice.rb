# frozen_string_literal: true

FactoryBot.define do
  factory :invoice, class: OpenStruct do
    lago_id { 'this_is_lago_internal_id' }
    sequential_id { 16 }
    number { "LAG-16" }
    version_number { '2' }
    issuing_date { '2022-06-02' }
    invoice_type { 'subscription' }
    status { 'finalized' }
    payment_status { 'succeeded' }
    currency { 'EUR' }
    fees_amount_cents { 100 }
    vat_amount_cents { 20 }
    coupons_amount_cents { 5 }
    credit_notes_amount_cents { 5 }
    sub_total_vat_excluded_amount_cents { 100 }
    sub_total_vat_included_amount_cents { 120 }
    total_amount_cents { 110 }
    prepaid_credit_amount_cents { 0 }
    file_url { 'http://file.url' }
    metadata do
      [
        {
          key: 'hello',
          value: 'standard',
        },
      ]
    end
  end
end
