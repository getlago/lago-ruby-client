# frozen_string_literal: true

FactoryBot.define do
  factory :create_usage_attribution_type, class: OpenStruct do
    code { 'team' }
    name { 'Team' }
    description { 'Teams of the organization' }
    attribution_keys { %w[team_id] }
    role { 'hierarchical' }
    parent_code { 'org' }
  end
end
