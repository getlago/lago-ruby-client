# frozen_string_literal: true

FactoryBot.define do
  factory :plan, class: OpenStruct do
    name { 'plan1' }
    code { 'plan_code' }
    interval { 'monthly' }
    description { 'desc' }
    pay_in_advance { false }
    amount_cents { 100 }
    amount_currency { 'EUR' }
    trial_period { 2 }
    bill_charges_monthly { false }
    charges do
      [
        {
          billable_metric_id: 'id',
          charge_model: 'standard',
          pay_in_advance: false,
          invoiceable: true,
          min_amount_cents: 0,
          properties: { amount: '0.22' },
        },
      ]
    end
  end
end
