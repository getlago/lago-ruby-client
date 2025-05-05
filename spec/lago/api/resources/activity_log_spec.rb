require 'spec_helper'

RSpec.describe Lago::Api::Resources::ActivityLog do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:activity_log_response) { load_fixture('activity_log') }
  let(:activity_log_id) { "1262046f-ea6e-423b-8bf7-3a985232f91b" }
  
  describe "#get" do
    let(:endpoint) { "https://api.getlago.com/api/v1/activity_logs/#{activity_log_id}" }
    let(:not_found_response) do
      {
        'status' => 404,
        'error' => 'Not Found',
        'code' => 'activity_log_not_found',
      }
    end

    context 'when activity log is successfully fetched' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: activity_log_response, status: 200)
      end

      it 'returns an activity log' do
        activity_log = resource.get(activity_log_id)

        expect(activity_log.activity_id).to eq(activity_log_id)
        expect(activity_log.activity_type).to eq("billable_metric.created")
      end
    end

    context 'when is not found' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: not_found_response.to_json, status: 404)
      end

      it 'raises an error' do
        expect { resource.get(activity_log_id) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:endpoint) { "https://api.getlago.com/api/v1/activity_logs#{options}" }
    let(:options) { "" }
    let(:activity_logs_response) { load_fixture('activity_logs_index') }
    let(:not_allowed_response) do
      {
        'status' => 405,
        'error' => "Method Not Allowed",
        'code' => '',
      }
    end

    context 'when there is no options' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: activity_logs_response, status: 200)
      end

      it 'returns activity logs on the first page' do
        response = resource.get_all

        expect(response['activity_logs'].first['activity_id']).to eq("1262046f-ea6e-423b-8bf7-3a985232f91b")
        expect(response['activity_logs'].first['activity_type']).to eq('billable_metric.created')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      let(:options_hash) { { per_page: 2, page: 1 } }
      let(:options) { "?#{URI.encode_www_form(options_hash)}" }
  
      before do
        stub_request(:get, endpoint)
          .to_return(body: activity_logs_response, status: 200)
      end

      it 'returns activity logs on selected page' do
        response = resource.get_all(options_hash)

        expect(response['activity_logs'].first['activity_id']).to eq("1262046f-ea6e-423b-8bf7-3a985232f91b")
        expect(response['activity_logs'].first['activity_type']).to eq('billable_metric.created')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: not_allowed_response.to_json, status: 405)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error Lago::Api::HttpError
      end
    end
  end

  [:create, :update, :destroy].each do |method|
    describe "##{method}" do
      it "does not have #{method}" do
        expect(resource.respond_to?(method)).to be(false)
      end
    end
  end
end
