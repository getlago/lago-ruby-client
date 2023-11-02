# frozen_string_literal: true

FactoryBot.define do
  factory :create_credit_note, class: OpenStruct do
    invoice_id { '1a901a90-1a90-1a90-1a90-1a901a901a90' }
    reason { 'duplicated_charge' }
    items { build_list(:create_credit_note_item, 2).map(&:to_h) }
  end

  factory :create_credit_note_item, class: OpenStruct do
    fee_id { '1a901a90-1a90-1a90-1a90-1a901a901a90' }
    amount_cents { 10 }
  end

  factory :update_credit_note, class: OpenStruct do
    refund_status { 'pending' }
  end

  factory :estimate_credit_note, class: OpenStruct do
    invoice_id { '1a901a90-1a90-1a90-1a90-1a901a901a90' }
    items { build_list(:create_credit_note_item, 2).map(&:to_h) }
  end
end
