# frozen_string_literal: true

FactoryBot.define do
  factory :create_payment_request, class: OpenStruct do
    lago_id { "89b6b61e-4dbc-4307-ac96-4abcfa9e3e2d" }
    email { "gavin@overdue.test" }
    amount_cents { 199_55 }
    amount_currency { "EUR" }
    payment_status { "pending" }
    created_at { "2024-06-30T10:59:51Z" }

    customer do
      {
        lago_id: "1a901a90-1a90-1a90-1a90-1a901a901a90",
        external_id: "gavin_001",
        name: "Gavin Belson",
        country: "US",
        address_line1: "5230 Penfield Ave",
        address_line2: "fzufuzfuz",
        state: "CA",
        zipcode: "91364",
        email: "dinesh@piedpiper.test",
        city: "Woodland Hills",
        url: "http://hooli.com",
        phone: "1-171-883-3711 x245",
        logo_url: "http://hooli.com/logo.png",
        legal_name: "Coleman-Blair",
        legal_number: "49-008-2965",
        net_payment_term: 30,
        tax_identification_number: "EU123456789",
        currency: "EUR",
        timezone: "Europe/Paris",
        sequential_id: 101,
        slug: "customer_101_slug",
        created_at: "2022-04-29T08:59:51Z",
        updated_at: "2022-04-29T08:59:51Z",
        applicable_timezone: "UTC",
        external_salesforce_id: "salesforce_999",
        finalize_zero_amount_invoice: "skip",
        billing_configuration: {
          invoice_grace_period: 3,
          payment_provider: "stripe",
          payment_provider_code: "stripe-eu-1",
          provider_customer_id: "cus_12345",
          sync_with_provider: true,
          document_locale: "fr",
          provider_payment_methods: ["card"]
        },
        shipping_address: {
          address_line1: "5230 Penfield Ave",
          city: "Woodland Hills",
          zipcode: "91364",
          state: "CA",
          country: "US"
        },
        metadata: [
          {
            lago_id: "7317916c-b64b-45df-8bfd-2fc80ed1679d",
            key: "lead_name",
            value: "John Doe",
            display_in_invoice: true,
          "created_at": "2022-04-29T08:59:51Z"
          }
        ]
      }
    end

    invoices do
      [
        {
          lago_id: "f8e194df-5d90-4382-b146-c881d2c67f28",
          sequential_id: 15,
          number: "LAG-1234-001-002",
          issuing_date: "2022-06-02",
          payment_dispute_lost_at: "2022-04-29T08:59:51Z",
          payment_due_date: "2022-06-02",
          payment_overdue: true,
          invoice_type: "one_off",
          version_number: 2,
          status: "finalized",
          payment_status: "pending",
          currency: "EUR",
          net_payment_term: 0,
          fees_amount_cents: 100_00,
          taxes_amount_cents: 20_00,
          coupons_amount_cents: 0,
          credit_notes_amount_cents: 0,
          sub_total_excluding_taxes_amount_cents: 100_00,
          sub_total_including_taxes_amount_cents: 120_00,
          prepaid_credit_amount_cents: 0,
          total_amount_cents: 120_00,
          progressive_billing_credit_amount_cents: 0,
          file_url: "https://lago-files/invoice_002.pdf",
        },
        {
          lago_id: "a20b1805-d54c-4e57-873d-721cc153035e",
          sequential_id: 22,
          number: "LAG-1234-009-012",
          issuing_date: "2022-07-08",
          payment_dispute_lost_at: nil,
          payment_due_date: "2022-07-08",
          payment_overdue: true,
          invoice_type: "one_off",
          version_number: 3,
          status: "finalized",
          payment_status: "failed",
          currency: "EUR",
          net_payment_term: 0,
          fees_amount_cents: 70_00,
          taxes_amount_cents: 9_55,
          coupons_amount_cents: 0,
          credit_notes_amount_cents: 0,
          sub_total_excluding_taxes_amount_cents: 70_00,
          sub_total_including_taxes_amount_cents: 79_55,
          prepaid_credit_amount_cents: 0,
          total_amount_cents: 79_55,
          progressive_billing_credit_amount_cents: 0,
          file_url: "https://lago-files/invoice_012.pdf",
        }
      ]
    end
  end
end
