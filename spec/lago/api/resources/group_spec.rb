# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Group do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:group) { build(:group) }
  let(:lago_id) { 'lago_internal_id' }
  let(:metric) { build(:create_billable_metric) }

  let(:not_found_response) do
    {
      'status' => 404,
      'error' => 'Not Found',
      'code' => 'billable_metric_not_found',
    }
  end

  describe '#get_all' do
    let(:response_body) do
      {
        'groups' => [group.to_h],
        'meta' => {
          'current_page' => 1,
          'next_page' => nil,
          'prev_page' => nil,
          'total_pages' => 1,
          'total_count' => 1,
        },
      }
    end

    before do
      stub_request(:get, "https://api.getlago.com/api/v1/billable_metrics/#{metric.code}/groups?per_page=2&page=1")
        .to_return(body: response_body.to_json, status: 200)
    end

    it 'returns a list of groups' do
      response = resource.get_all(metric.code, { per_page: 2, page: 1 })

      expect(response['groups'].first['lago_id']).to eq(group.lago_id)
      expect(response['meta']['current_page']).to eq(1)
    end
  end
end
