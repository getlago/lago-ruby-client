FactoryBot.define do
  factory :customer_usage, class: OpenStruct do
    from_date { '2022-07-01' }
    to_date { '2022-07-31' }
    issuing_date { '2022-08-01' }
    amount_cents { 123 }
    amount_currency { 'EUR' }
    total_amount_cents { 123 }
    total_amount_currency { 'EUR' }
    vat_amount_cents { 0 }
    vat_amount_currency { 'EUR' }
    charges_usage do
      [{
        'units': '1.0',
        'amount_cents': 123,
        'amount_currency': 'EUR',
        'charge': {
          'lago_id': '5eb02857-a71e-4ea2-bcf9-57d3a41bc6ba',
          'charge_model': 'graduated'
        },
        'billable_metric': {
          'lago_id': '99a6094e-199b-4101-896a-54e927ce7bd7',
          'name': 'Usage metric',
          'code': 'usage_metric',
          'aggregation_type': 'sum'
        }
      }]
    end
  end
end
