# frozen_string_literal: true

FactoryBot.define do
  factory :update_organization, class: OpenStruct do
    webhook_url { 'http://example.com/webhooks/' }
    country { 'country' }
    address_line1 { 'line1' }
    address_line2 { 'line2' }
    state { 'state' }
    zipcode { '10000' }
    email { 'john@email.com' }
    city { 'city' }
    legal_name { 'legal1' }
    legal_number { 'legal2' }
    tax_identification_number { 'EU123456789' }
    billing_configuration do
      {
        invoice_footer: 'footer',
        invoice_grace_period: 2,
        document_locale: 'fr',
      }
    end
    timezone { 'America/New_York' }
  end
end
