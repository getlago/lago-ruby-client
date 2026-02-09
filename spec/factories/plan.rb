# frozen_string_literal: true

FactoryBot.define do
  factory :create_plan, class: OpenStruct do
    name { 'plan1' }
    invoice_display_name { 'PLN1' }
    code { 'plan_code' }
    interval { 'monthly' }
    description { 'desc' }
    pay_in_advance { false }
    amount_cents { 100 }
    amount_currency { 'EUR' }
    trial_period { 2 }
    bill_charges_monthly { false }
    bill_fixed_charges_monthly { true }
    metadata { { 'foo' => 'bar', 'baz' => 'qux' } }
    charges do
      [
        {
          billable_metric_id: 'id',
          charge_model: 'standard',
          pay_in_advance: false,
          invoiceable: true,
          invoice_display_name: 'Charge 1',
          min_amount_cents: 0,
          accepts_target_wallet: false,
          properties: { amount: '0.22' },
        },
      ]
    end
    minimum_commitment do
      {
        invoice_display_name: 'Minimum commitment (C1)',
        amount_cents: 100,
      }
    end
    fixed_charges do
      [
        {
          add_on_id: 'ao901a90-1a90-1a90-1a90-1a901a901a90',
          charge_model: 'standard',
          code: 'fixed_setup',
          invoice_display_name: 'Setup Fee',
          units: 1,
          pay_in_advance: true,
          prorated: false,
          properties: { amount: '500' },
          tax_codes: ['tax_code'],
        },
      ]
    end
  end
end
