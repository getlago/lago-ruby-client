FactoryBot.define do
  factory :minimum_commitment, class: OpenStruct do
    invoice_display_name { 'Minimum commitment (C1)' }
    plan_code { 'plan_code' }
    interval { 'monthly' }
    amount_cents { 200 }
  end
end
