FactoryBot.define do
  factory :organization, class: OpenStruct do
    webhook_url { 'http://example.com/webhooks/' }
    vat_rate { 20 }
    country { 'country' }
    address_line1 { 'line1' }
    address_line2 { 'line2' }
    state { 'state' }
    zipcode { '10000' }
    email { 'john@email.com' }
    city { 'city' }
    legal_name { 'legal1' }
    legal_number { 'legal2' }
    invoice_footer { 'footer' }
  end
end
