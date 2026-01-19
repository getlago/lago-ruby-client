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
        expect(plan.bill_fixed_charges_monthly).to be(true)

        expect(plan.minimum_commitment.invoice_display_name).to eq(minimum_commitment.invoice_display_name)
        expect(plan.minimum_commitment.taxes.map(&:code)).to eq(tax_codes)

        expect(plan.fixed_charges).to be_an(Array)
        expect(plan.fixed_charges.first.lago_id).to eq('fc901a90-1a90-1a90-1a90-1a901a901a90')
        expect(plan.fixed_charges.first.charge_model).to eq('standard')
        expect(plan.fixed_charges.first.invoice_display_name).to eq('Setup Fee')
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
        expect(response['plans'].first['charges'].first['properties']['pricing_group_keys']).to eq(['agent_name'])
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

  describe '#get_entitlements' do
    let(:json_response) { load_fixture('plan_entitlements') }
    let(:plan_code) { 'plan_123' }

    context 'when entitlements are successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{plan_code}/entitlements")
          .to_return(body: json_response, status: 200)
      end

      it 'returns entitlements' do
        entitlements = resource.get_entitlements(plan_code)

        expect(entitlements).to be_an(Array)
        expect(entitlements.map(&:code)).to eq %w[seats analytics_api salesforce sso]
      end
    end
  end

  describe '#create_entitlements' do
    let(:plan_code) { 'plan_123' }
    let(:params) do
      {
        seats: {
          root: true,
        },
      }
    end
    let(:response_body) { { entitlements: { worked: true } }.to_json }

    context 'when entitlements are successfully created' do
      before do
        stub_request(:post, "https://api.getlago.com/api/v1/plans/#{plan_code}/entitlements")
          .with(body: { entitlements: params })
          .to_return(body: response_body, status: 200)
      end

      it 'returns response' do
        response = resource.create_entitlements(plan_code, params)

        expect(response.worked).to be true
      end
    end
  end

  describe '#update_entitlements' do
    let(:plan_code) { 'plan_123' }
    let(:params) do
      {
        seats: {
          root: true,
        },
      }
    end
    let(:response_body) { { entitlements: { worked: true } }.to_json }

    context 'when entitlements are successfully updated' do
      before do
        stub_request(:patch, "https://api.getlago.com/api/v1/plans/#{plan_code}/entitlements")
          .with(body: { entitlements: params })
          .to_return(body: response_body, status: 200)
      end

      it 'returns response' do
        response = resource.update_entitlements(plan_code, params)

        expect(response.worked).to be true
      end
    end
  end

  describe '#get_entitlement' do
    let(:plan_code) { 'plan_123' }
    let(:feature_code) { 'seats' }
    let(:json_response) { { entitlement: { worked: true } }.to_json }

    context 'when entitlement is successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{plan_code}/entitlements/#{feature_code}")
          .to_return(body: json_response, status: 200)
      end

      it 'returns entitlement' do
        response = resource.get_entitlement(plan_code, feature_code)

        expect(response.worked).to be true
      end
    end
  end

  describe '#delete_entitlement' do
    let(:plan_code) { 'plan_123' }
    let(:feature_code) { 'seats' }
    let(:response_body) { { entitlement: { worked: true } }.to_json }

    context 'when entitlement is successfully deleted' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/plans/#{plan_code}/entitlements/#{feature_code}")
          .to_return(body: response_body, status: 200)
      end

      it 'returns response' do
        response = resource.delete_entitlement(plan_code, feature_code)

        expect(response.worked).to be true
      end
    end

    context 'when entitlement deletion fails' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/plans/#{plan_code}/entitlements/#{feature_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.delete_entitlement(plan_code, feature_code) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#delete_entitlement_privilege' do
    let(:plan_code) { 'plan_123' }
    let(:entitlement_code) { 'seats' }
    let(:privilege_code) { 'max_admins' }
    let(:response_body) { { entitlement: { worked: true } }.to_json }

    context 'when entitlement privilege is successfully deleted' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/plans/#{plan_code}/entitlements/#{entitlement_code}/privileges/#{privilege_code}")
          .to_return(body: response_body, status: 200)
      end

      it 'returns response' do
        response = resource.delete_entitlement_privilege(plan_code, entitlement_code, privilege_code)

        expect(response.worked).to be true
      end
    end
  end
end
