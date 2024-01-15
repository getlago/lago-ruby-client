# frozen_string_literal: true

FactoryBot.define do
  factory :create_customer, class: OpenStruct do
    external_id { '1a901a90-1a90-1a90-1a90-1a901a901a90' }
    name { 'Gavin Belson' }
    country { 'US' }
    address_line1 { '5230 Penfield Ave' }
    address_line2 { 'fzufuzfuz' }
    state { 'CA' }
    zipcode { '91364' }
    email { 'dinesh@piedpiper.test' }
    city { 'Woodland Hills' }
    url { '<http://hooli.com>' }
    phone { '1-171-883-3711 x245' }
    logo_url { 'http://hooli.com/logo.png' }
    legal_name { 'Coleman-Blair' }
    legal_number { '49-008-2965' }
    net_payment_term { nil }
    tax_identification_number { 'EU123456789' }
    billing_configuration do
      {
        invoice_grace_period: 3,
        payment_provider: 'stripe',
        payment_provider_code: 'stripe-eu-1',
        provider_customer_id: 'cus_123456',
        sync_with_provider: true,
        document_locale: 'fr',
      }
    end
    metadata do
      [
        {
          key: 'hello',
          value: 'standard',
          display_in_invoice: true,
        },
      ]
    end
    currency { 'EUR' }
    tax_codes { ['tax_code'] }
    timezone { 'Europe/Paris' }
  end
end
