# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Plan do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:plan_response) { load_fixture('plan') }
  let(:plan_json) { JSON.parse(plan_response)['plan'] }
  let(:plan_id) { plan_json['lago_id'] }
  let(:plan_code) { plan_json['code'] }
  let(:plan_name) { plan_json['name'] }
  let(:plan_dsplay_name) { plan_json['invoice_display_name'] }

  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#create' do
    let(:tax_codes) { ['tax_code'] }
    let(:minimum_commitment) { create(:minimum_commitment) }
    let(:params) { create(:create_plan).to_h.merge(tax_codes: tax_codes) }
    let(:body) do
      { 'plan' => params }
    end

    context 'when plan is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/plans')
          .with(body: body)
          .to_return(body: plan_response, status: 200)
      end

      it 'returns an plan' do
        plan = resource.create(params)

        expect(plan.lago_id).to eq(plan_id)
        expect(plan.name).to eq(plan_name)
        expect(plan.invoice_display_name).to eq(plan_dsplay_name)
        expect(plan.taxes.map(&:code)).to eq(tax_codes)

        expect(plan.minimum_commitment.invoice_display_name).to eq(minimum_commitment.invoice_display_name)
        expect(plan.minimum_commitment.taxes.map(&:code)).to eq(tax_codes)
      end
    end

    context 'when plan failed to create' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/plans')
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#update' do
    let(:params) { create(:create_plan).to_h }

    context 'when plan is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/plans/#{plan_code}")
          .with(body: { plan: params })
          .to_return(body: plan_response, status: 200)
      end

      it 'returns an plan' do
        plan = resource.update(params, plan_code)

        expect(plan.lago_id).to eq(plan_id)
        expect(plan.name).to eq(plan_name)
        expect(plan.invoice_display_name).to eq(plan_dsplay_name)
        expect(plan.minimum_commitment.invoice_display_name).to eq('Minimum commitment (C1)')
      end
    end

    context 'when plan failed to update' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/plans/#{plan_code}")
          .with(body: { plan: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, plan_code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get' do
    context 'when plan is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{plan_code}")
          .to_return(body: plan_response, status: 200)
      end

      it 'returns an plan' do
        plan = resource.get(plan_code)

        expect(plan.lago_id).to eq(plan_id)
        expect(plan.name).to eq(plan_name)
        expect(plan.invoice_display_name).to eq(plan_dsplay_name)
        expect(plan.minimum_commitment.invoice_display_name).to eq('Minimum commitment (C1)')
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{plan_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get(plan_code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#destroy' do
    context 'when plan is successfully destroyed' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/plans/#{plan_code}")
          .to_return(body: plan_response, status: 200)
      end

      it 'returns an plan' do
        plan = resource.destroy(plan_code)

        expect(plan.lago_id).to eq(plan_id)
        expect(plan.name).to eq(plan_name)
        expect(plan.invoice_display_name).to eq(plan_dsplay_name)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/plans/#{plan_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy(plan_code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:plans_response) { load_fixture('plans') }

    context 'when there is no options' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/plans')
          .to_return(body: plans_response, status: 200)
      end

      it 'returns plans on the first page' do
        response = resource.get_all

        expect(response['plans'].first['lago_id']).to eq(plan_id)
        expect(response['plans'].first['name']).to eq(plan_name)
        expect(response['plans'].first['invoice_display_name']).to eq(plan_dsplay_name)
        expect(response['plans'].first['charges'].first['invoice_display_name']).to eq('Charge 1')
        expect(response['plans'].first['charges'].first['properties']['grouped_by']).to eq(['agent_name'])
        expect(response['plans'].first['minimum_commitment']['invoice_display_name']).to eq('Minimum commitment (C1)')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/plans?per_page=2&page=1')
          .to_return(body: plans_response, status: 200)
      end

      it 'returns plans on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['plans'].first['lago_id']).to eq(plan_id)
        expect(response['plans'].first['name']).to eq(plan_name)
        expect(response['plans'].first['invoice_display_name']).to eq(plan_dsplay_name)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/plans')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
