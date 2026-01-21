FactoryBot.define do
  factory :wallet, class: OpenStruct do
    name { 'wallet name' }
    external_customer_id { '12345' }
    expiration_at { '2022-07-07T23:59:59Z' }
    rate_amount { '1' }
    paid_credits { '100' }
    granted_credits { '100' }
    metadata { { 'foo' => 'bar', 'baz' => 'qux' } }
    applies_to do
      {
        fee_types: %w[charge],
        billable_metric_codes: %w[bm1]
      }
    end
    recurring_transaction_rules do
      [
        {
          trigger: 'interval',
          interval: 'monthly',
          paid_credits: '105',
          granted_credits: '105',
          started_at: nil,
          expiration_at: '2026-12-31T23:59:59Z',
          threshold_credits: '0',
          method: 'fixed',
          transaction_name: 'Recurring Transaction Rule'
        },
      ]
    end
  end
end
