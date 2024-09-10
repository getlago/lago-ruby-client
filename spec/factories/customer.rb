# frozen_string_literal: true

FactoryBot.define do
  factory :create_customer, class: OpenStruct do
    external_id { '1a901a90-1a90-1a90-1a90-1a901a901a90' }
    name { 'Gavin Belson' }
    firstname { 'Gavin' }
    lastname { 'Belson' }
    customer_type { 'individual' }
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
    finalize_zero_amount_invoice { 'inherit' }
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
    shipping_address do
      {
        address_line1: '5230 Penfield Ave',
        city: 'Woodland Hills',
        zipcode: '91364',
        state: 'CA',
        country: 'US',
      }
    end
    integration_customers do
      [
        {
          integration_type: 'netsuite',
          integration_code: 'test-123',
          subsidiary_id: '2',
          sync_with_provider: true,
        },
      ]
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
