# frozen_string_literal: true

FactoryBot.define do
  factory :create_usage_attribution_type, class: OpenStruct do
    code { 'team' }
    name { 'Team' }
    attribution_key { 'team_id' }
    role { 'team' }
    parent_code { 'org' }
  end
end
