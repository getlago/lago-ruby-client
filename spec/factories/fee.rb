# frozen_string_literal: true

FactoryBot.define do
  factory :fee, class: OpenStruct do
    lago_id { 'this_is_lago_internal_id' }
    lago_group_id { 'this_is_lago_group_internal_id' }
    amount_cents { 120 }
    amount_currency { 'EUR' }
    vat_amount_cents { 20 }
    vat_amount_currency { 'EUR' }
    units { '10.0' }
    events_count { 10 }

    association :item, factory: :fee_item
  end

  factory :fee_item, class: OpenStruct do
    type { 'charge' }
    code { 'fee_code' }
    name { 'Fee Name' }
  end
end
