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

        expect(plan.charges.first.accepts_target_wallet).to be(false)

        expect(plan.fixed_charges).to be_an(Array)
        expect(plan.fixed_charges.first.lago_id).to eq('fc901a90-1a90-1a90-1a90-1a901a901a90')
        expect(plan.fixed_charges.first.charge_model).to eq('standard')
        expect(plan.fixed_charges.first.invoice_display_name).to eq('Setup Fee')

        expect(plan.metadata.foo).to eq('bar')
        expect(plan.metadata.baz).to eq('qux')
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

  describe '#replace_metadata' do
    let(:metadata) { { 'foo' => 'bar', 'baz' => 'qux' } }
    let(:metadata_response) { { metadata: metadata }.to_json }

    before do
      stub_request(:post, "https://api.getlago.com/api/v1/plans/#{plan_code}/metadata")
        .with(body: { metadata: metadata })
        .to_return(body: metadata_response, status: 200)
    end

    it 'returns metadata hash' do
      response = resource.replace_metadata(plan_code, metadata)

      expect(response).to eq(metadata)
    end
  end

  describe '#merge_metadata' do
    let(:metadata) { { 'foo' => 'qux' } }
    let(:metadata_response) { { metadata: metadata }.to_json }

    before do
      stub_request(:patch, "https://api.getlago.com/api/v1/plans/#{plan_code}/metadata")
        .with(body: { metadata: metadata })
        .to_return(body: metadata_response, status: 200)
    end

    it 'returns metadata hash' do
      response = resource.merge_metadata(plan_code, metadata)

      expect(response).to eq(metadata)
    end
  end

  describe '#delete_all_metadata' do
    let(:metadata_response) { { metadata: nil }.to_json }

    before do
      stub_request(:delete, "https://api.getlago.com/api/v1/plans/#{plan_code}/metadata")
        .to_return(body: metadata_response, status: 200)
    end

    it 'returns nil metadata' do
      response = resource.delete_all_metadata(plan_code)

      expect(response).to be_nil
    end
  end

  describe '#delete_metadata_key' do
    let(:key) { 'foo' }
    let(:remaining_metadata) { { 'baz' => 'qux' } }
    let(:metadata_response) { { metadata: remaining_metadata }.to_json }

    before do
      stub_request(:delete, "https://api.getlago.com/api/v1/plans/#{plan_code}/metadata/#{key}")
        .to_return(body: metadata_response, status: 200)
    end

    it 'returns remaining metadata hash' do
      response = resource.delete_metadata_key(plan_code, key)

      expect(response).to eq(remaining_metadata)
    end
  end

  # Charges

  describe '#get_all_charges' do
    let(:json_response) { load_fixture('plan_charges') }

    context 'when charges are successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges")
          .to_return(body: json_response, status: 200)
      end

      it 'returns charges with meta' do
        response = resource.get_all_charges(plan_code)

        expect(response['charges'].first['lago_id']).to eq('51c1e851-5be6-4343-a0ee-39a81d8b4ee1')
        expect(response['charges'].first['code']).to eq('charge_code')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges?per_page=2&page=1")
          .to_return(body: json_response, status: 200)
      end

      it 'returns charges on selected page' do
        response = resource.get_all_charges(plan_code, { per_page: 2, page: 1 })

        expect(response['charges'].first['lago_id']).to eq('51c1e851-5be6-4343-a0ee-39a81d8b4ee1')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all_charges(plan_code) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#get_charge' do
    let(:json_response) { load_fixture('plan_charge') }
    let(:charge_response) { JSON.parse(json_response) }
    let(:charge_code) { charge_response['charge']['code'] }

    context 'when charge is successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges/#{charge_code}")
          .to_return(body: json_response, status: 200)
      end

      it 'returns charge' do
        charge = resource.get_charge(plan_code, charge_code)

        expect(charge.lago_id).to eq('51c1e851-5be6-4343-a0ee-39a81d8b4ee1')
        expect(charge.code).to eq(charge_code)
      end
    end

    context 'when charge is not found' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges/#{charge_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_charge(plan_code, charge_code) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#create_charge' do
    let(:json_response) { load_fixture('plan_charge') }
    let(:params) do
      {
        billable_metric_id: 'a6947936-628f-4945-8857-db6858ee7941',
        code: 'charge_code',
        charge_model: 'standard',
        properties: { amount: '0.22' },
      }
    end

    context 'when charge is successfully created' do
      before do
        stub_request(:post, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges")
          .with(body: { charge: params })
          .to_return(body: json_response, status: 200)
      end

      it 'returns charge' do
        charge = resource.create_charge(plan_code, params)

        expect(charge.lago_id).to eq('51c1e851-5be6-4343-a0ee-39a81d8b4ee1')
        expect(charge.code).to eq('charge_code')
      end
    end

    context 'when charge creation fails' do
      before do
        stub_request(:post, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges")
          .with(body: { charge: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create_charge(plan_code, params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#update_charge' do
    let(:json_response) { load_fixture('plan_charge') }
    let(:charge_code) { 'charge_code' }
    let(:params) { { invoice_display_name: 'Updated Setup' } }

    context 'when charge is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges/#{charge_code}")
          .with(body: { charge: params })
          .to_return(body: json_response, status: 200)
      end

      it 'returns charge' do
        charge = resource.update_charge(plan_code, charge_code, params)

        expect(charge.lago_id).to eq('51c1e851-5be6-4343-a0ee-39a81d8b4ee1')
        expect(charge.code).to eq(charge_code)
      end
    end

    context 'when charge update fails' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges/#{charge_code}")
          .with(body: { charge: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update_charge(plan_code, charge_code, params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#destroy_charge' do
    let(:json_response) { load_fixture('plan_charge') }
    let(:charge_code) { 'charge_code' }

    context 'when charge is successfully destroyed' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges/#{charge_code}")
          .to_return(body: json_response, status: 200)
      end

      it 'returns charge' do
        charge = resource.destroy_charge(plan_code, charge_code)

        expect(charge.lago_id).to eq('51c1e851-5be6-4343-a0ee-39a81d8b4ee1')
        expect(charge.code).to eq(charge_code)
      end
    end

    context 'when charge destruction fails' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges/#{charge_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy_charge(plan_code, charge_code) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  # Fixed Charges

  describe '#get_all_fixed_charges' do
    let(:json_response) { load_fixture('plan_fixed_charges') }

    context 'when fixed charges are successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{plan_code}/fixed_charges")
          .to_return(body: json_response, status: 200)
      end

      it 'returns fixed charges with meta' do
        response = resource.get_all_fixed_charges(plan_code)

        expect(response['fixed_charges'].first['lago_id']).to eq('fc901a90-1a90-1a90-1a90-1a901a901a90')
        expect(response['fixed_charges'].first['code']).to eq('fixed_setup')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{plan_code}/fixed_charges")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all_fixed_charges(plan_code) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#get_fixed_charge' do
    let(:json_response) { load_fixture('plan_fixed_charge') }
    let(:fixed_charge_code) { 'fixed_setup' }

    context 'when fixed charge is successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{plan_code}/fixed_charges/#{fixed_charge_code}")
          .to_return(body: json_response, status: 200)
      end

      it 'returns fixed charge' do
        fixed_charge = resource.get_fixed_charge(plan_code, fixed_charge_code)

        expect(fixed_charge.lago_id).to eq('fc901a90-1a90-1a90-1a90-1a901a901a90')
        expect(fixed_charge.code).to eq(fixed_charge_code)
      end
    end

    context 'when fixed charge is not found' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{plan_code}/fixed_charges/#{fixed_charge_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_fixed_charge(plan_code, fixed_charge_code) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#create_fixed_charge' do
    let(:json_response) { load_fixture('plan_fixed_charge') }
    let(:params) do
      {
        add_on_id: 'ao901a90-1a90-1a90-1a90-1a901a901a90',
        code: 'fixed_setup',
        charge_model: 'standard',
        properties: { amount: '500' },
      }
    end

    context 'when fixed charge is successfully created' do
      before do
        stub_request(:post, "https://api.getlago.com/api/v1/plans/#{plan_code}/fixed_charges")
          .with(body: { fixed_charge: params })
          .to_return(body: json_response, status: 200)
      end

      it 'returns fixed charge' do
        fixed_charge = resource.create_fixed_charge(plan_code, params)

        expect(fixed_charge.lago_id).to eq('fc901a90-1a90-1a90-1a90-1a901a901a90')
        expect(fixed_charge.code).to eq('fixed_setup')
      end
    end

    context 'when fixed charge creation fails' do
      before do
        stub_request(:post, "https://api.getlago.com/api/v1/plans/#{plan_code}/fixed_charges")
          .with(body: { fixed_charge: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create_fixed_charge(plan_code, params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#update_fixed_charge' do
    let(:json_response) { load_fixture('plan_fixed_charge') }
    let(:fixed_charge_code) { 'fixed_setup' }
    let(:params) { { invoice_display_name: 'Updated Setup Fee' } }

    context 'when fixed charge is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/plans/#{plan_code}/fixed_charges/#{fixed_charge_code}")
          .with(body: { fixed_charge: params })
          .to_return(body: json_response, status: 200)
      end

      it 'returns fixed charge' do
        fixed_charge = resource.update_fixed_charge(plan_code, fixed_charge_code, params)

        expect(fixed_charge.lago_id).to eq('fc901a90-1a90-1a90-1a90-1a901a901a90')
        expect(fixed_charge.code).to eq(fixed_charge_code)
      end
    end

    context 'when fixed charge update fails' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/plans/#{plan_code}/fixed_charges/#{fixed_charge_code}")
          .with(body: { fixed_charge: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect do
          resource.update_fixed_charge(plan_code, fixed_charge_code, params)
        end.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#destroy_fixed_charge' do
    let(:json_response) { load_fixture('plan_fixed_charge') }
    let(:fixed_charge_code) { 'fixed_setup' }

    context 'when fixed charge is successfully destroyed' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/plans/#{plan_code}/fixed_charges/#{fixed_charge_code}")
          .to_return(body: json_response, status: 200)
      end

      it 'returns fixed charge' do
        fixed_charge = resource.destroy_fixed_charge(plan_code, fixed_charge_code)

        expect(fixed_charge.lago_id).to eq('fc901a90-1a90-1a90-1a90-1a901a901a90')
        expect(fixed_charge.code).to eq(fixed_charge_code)
      end
    end

    context 'when fixed charge destruction fails' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/plans/#{plan_code}/fixed_charges/#{fixed_charge_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy_fixed_charge(plan_code, fixed_charge_code) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  # Charge Filters

  describe '#get_all_charge_filters' do
    let(:json_response) { load_fixture('plan_charge_filters') }
    let(:charge_code) { 'charge_code' }

    context 'when charge filters are successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges/#{charge_code}/filters")
          .to_return(body: json_response, status: 200)
      end

      it 'returns filters with meta' do
        response = resource.get_all_charge_filters(plan_code, charge_code)

        expect(response['filters'].first['lago_id']).to eq('f1901a90-1a90-1a90-1a90-1a901a901a90')
        expect(response['filters'].first['invoice_display_name']).to eq('From France')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges/#{charge_code}/filters")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all_charge_filters(plan_code, charge_code) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#get_charge_filter' do
    let(:json_response) { load_fixture('plan_charge_filter') }
    let(:charge_code) { 'charge_code' }
    let(:filter_id) { 'f1901a90-1a90-1a90-1a90-1a901a901a90' }

    context 'when charge filter is successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges/#{charge_code}/filters/#{filter_id}")
          .to_return(body: json_response, status: 200)
      end

      it 'returns filter' do
        filter = resource.get_charge_filter(plan_code, charge_code, filter_id)

        expect(filter.lago_id).to eq(filter_id)
        expect(filter.invoice_display_name).to eq('From France')
      end
    end

    context 'when charge filter is not found' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges/#{charge_code}/filters/#{filter_id}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_charge_filter(plan_code, charge_code, filter_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#create_charge_filter' do
    let(:json_response) { load_fixture('plan_charge_filter') }
    let(:charge_code) { 'charge_code' }
    let(:params) do
      {
        invoice_display_name: 'From France',
        properties: { amount: '0.33' },
        values: { country: ['France'] },
      }
    end

    context 'when charge filter is successfully created' do
      before do
        stub_request(:post, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges/#{charge_code}/filters")
          .with(body: { filter: params })
          .to_return(body: json_response, status: 200)
      end

      it 'returns filter' do
        filter = resource.create_charge_filter(plan_code, charge_code, params)

        expect(filter.lago_id).to eq('f1901a90-1a90-1a90-1a90-1a901a901a90')
        expect(filter.invoice_display_name).to eq('From France')
      end
    end

    context 'when charge filter creation fails' do
      before do
        stub_request(:post, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges/#{charge_code}/filters")
          .with(body: { filter: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create_charge_filter(plan_code, charge_code, params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#update_charge_filter' do
    let(:json_response) { load_fixture('plan_charge_filter') }
    let(:charge_code) { 'charge_code' }
    let(:filter_id) { 'f1901a90-1a90-1a90-1a90-1a901a901a90' }
    let(:params) { { invoice_display_name: 'Updated Filter' } }

    context 'when charge filter is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges/#{charge_code}/filters/#{filter_id}")
          .with(body: { filter: params })
          .to_return(body: json_response, status: 200)
      end

      it 'returns filter' do
        filter = resource.update_charge_filter(plan_code, charge_code, filter_id, params)

        expect(filter.lago_id).to eq(filter_id)
        expect(filter.invoice_display_name).to eq('From France')
      end
    end

    context 'when charge filter update fails' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges/#{charge_code}/filters/#{filter_id}")
          .with(body: { filter: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect do
          resource.update_charge_filter(plan_code, charge_code, filter_id, params)
        end.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#destroy_charge_filter' do
    let(:json_response) { load_fixture('plan_charge_filter') }
    let(:charge_code) { 'charge_code' }
    let(:filter_id) { 'f1901a90-1a90-1a90-1a90-1a901a901a90' }

    context 'when charge filter is successfully destroyed' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges/#{charge_code}/filters/#{filter_id}")
          .to_return(body: json_response, status: 200)
      end

      it 'returns filter' do
        filter = resource.destroy_charge_filter(plan_code, charge_code, filter_id)

        expect(filter.lago_id).to eq(filter_id)
        expect(filter.invoice_display_name).to eq('From France')
      end
    end

    context 'when charge filter destruction fails' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/plans/#{plan_code}/charges/#{charge_code}/filters/#{filter_id}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect do
          resource.destroy_charge_filter(plan_code, charge_code, filter_id)
        end.to raise_error(Lago::Api::HttpError)
      end
    end
  end
end
