FactoryBot.define do
  factory :event, class: OpenStruct do
    transaction_id { 'UNIQUE_ID' }
    external_subscription_id { '5eb02857-a71e-4ea2-bcf9-57d8885990ba' }
    code { '123' }
    timestamp { '2022-05-05T12:27:30Z' }
    precise_total_amount_cents { '1000.12' }
    properties do
      {
        'custom_field' => 'custom'
      }
    end
  end

  factory :batch_event, class: OpenStruct do
    events do
      [
        {
          'transaction_id' => 'UNIQUE_ID',
          'external_subscription_id' => '5eb02857-a71e-4ea2-bcf9-57d8885990ba',
          'code' => '123',
          'timestamp' => '2022-05-05T12:27:30Z',
          'properties' => {
            'custom_field' => 'custom',
          },
        },
      ]
    end
  end

  factory :estimate_fees_event, class: OpenStruct do
    external_subscription_id { '5eb02857-a71e-4ea2-bcf9-57d8885990ba' }
    code { '123' }
    properties do
      {
        'custom_field' => 'custom',
      }
    end
  end
end
