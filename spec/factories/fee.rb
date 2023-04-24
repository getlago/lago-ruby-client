# frozen_string_literal: true

FactoryBot.define do
  factory :fee, class: OpenStruct do
    lago_id { 'b82f64f2-3360-4a1a-a800-6d3489e73c04' }
    lago_group_id { 'b82f64f2-3360-4a1a-a800-6d3489e73c04' }
    lago_invoice_id { 'b82f64f2-3360-4a1a-a800-6d3489e73c04' }
    lago_true_up_fee_id { 'b82f64f2-3360-4a1a-a800-6d3489e73c04' }
    external_subscription_id { 'external-id' }
    amount_cents { 120 }
    amount_currency { 'EUR' }
    vat_amount_cents { 20 }
    vat_amount_currency { 'EUR' }
    total_amount_cents { 140 }
    total_amount_currency { 'EUR' }
    units { '10.0' }
    events_count { 10 }
    payment_status { 'succeeded' }

    association :item, factory: :fee_item
  end

  factory :fee_item, class: OpenStruct do
    type { 'charge' }
    code { 'fee_code' }
    name { 'Fee Name' }
    lago_item_id { 'b82f64f2-3360-4a1a-a800-6d3489e73c04' }
    item_type { 'AddOn' }
  end
end
