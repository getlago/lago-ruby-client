FactoryBot.define do
  factory :create_billable_metric, class: OpenStruct do
    name { 'BM1' }
    code { 'BM_code' }
    description { 'description' }
    recurring { false }
    aggregation_type { 'sum_agg' }
    field_name { 'amount_sum' }
  end

  factory :update_billable_metric, parent: :create_billable_metric do
  end
end
