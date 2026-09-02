# frozen_string_literal: true

FactoryBot.define do
  factory :create_invoice, class: OpenStruct do
    external_customer_id { '_ID_' }
    currency { 'EUR' }
    fees do
      [
        {
          add_on_code: '123',
          description: 'desc',
        }
      ]
    end
  end

  factory :update_invoice, class: OpenStruct do
    payment_status { 'succeeded' }
    metadata do
      [
        {
          key: 'hello',
          value: 'standard',
        },
      ]
    end
  end
end
