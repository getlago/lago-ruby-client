# frozen_string_literal: true

FactoryBot.define do
  factory :create_billing_entity, class: OpenStruct do
    code { 'BILL-001' }
    name { 'Test Billing Entity' }
    address_line1 { '123 Main St' }
    address_line2 { 'Suite 100' }
    city { 'New York' }
    state { 'NY' }
    zipcode { '10001' }
    country { 'US' }
    email { 'billing@example.com' }
    phone { '+1234567890' }
    default_currency { 'USD' }
    timezone { 'America/New_York' }
    document_numbering { 'per_customer' }
    document_number_prefix { 'BILL-001' }
    finalize_zero_amount_invoice { true }
    net_payment_term { 0 }
    eu_tax_management { false }
    logo { 'base64 encoded image' }
    legal_name { 'Legal Company Name' }
    legal_number { '123456789' }
    tax_identification_number { 'US123456789' }
    email_settings { ['invoice.finalized'] }
    billing_configuration do
      {
        invoice_footer: 'Thank you for your business',
        invoice_grace_period: 2,
        document_locale: 'en',
      }
    end
  end

  factory :update_billing_entity, class: OpenStruct do
    name { 'Updated Billing Entity' }
    address_line1 { '456 New St' }
    city { 'Los Angeles' }
    state { 'CA' }
    zipcode { '90001' }
    country { 'US' }
    email { 'updated@example.com' }
    tax_codes { ['TAX-002', 'TAX-032'] }
    billing_configuration do
      {
        invoice_footer: 'Updated footer',
        invoice_grace_period: 3,
        document_locale: 'fr',
      }
    end
    invoice_custom_section_codes { ['CUSTOM-001', 'CUSTOM-002'] }
  end
end
