FactoryBot.define do
  factory :invoice, class: OpenStruct do
    lago_id { 'this_is_lago_internal_id' }
    sequential_id { 16 }
    from_date { '2022-06-02' }
    to_date { '2022-06-02' }
    issuing_date { '2022-06-02' }
    invoice_type { 'type1' }
    payment_status { 'succeeded' }
    amount_cents { 100 }
    amount_currency { 'EUR' }
    vat_amount_cents { 20 }
    vat_amount_currency { 'EUR' }
    total_amount_cents { 120 }
    total_amount_currency { 'EUR' }
    file_url { 'http://file.url' }
  end
end
