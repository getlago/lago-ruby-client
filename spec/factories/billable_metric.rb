FactoryBot.define do
  factory :billable_metric, class: OpenStruct do
    name { 'BM1' }
    code { 'BM_code' }
    description { 'description' }
    aggregation_type { 'sum_agg' }
    field_name { 'amount_sum' }
  end
end
