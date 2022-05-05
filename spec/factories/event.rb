FactoryBot.define do
  factory :event, class: OpenStruct do
    customer_id { '5eb02857-a71e-4ea2-bcf9-57d8885990ba' }
    code { '123' }
    timestamp { '2022-05-05T12:27:30Z' }
    properties do
      {
        'custom_field' => 'custom'
      }
    end
  end
end
