FactoryBot.define do
  factory :wallet_transaction, class: OpenStruct do
    wallet_id { '123' }
    paid_credits { '100' }
    granted_credits { '100' }
    voided_credits { '0' }
  end
end
