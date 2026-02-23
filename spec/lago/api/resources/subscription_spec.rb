# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Subscription do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:factory_subscription) { build(:subscription) }
  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end
  let(:response) do
    {
      'subscription' => factory_subscription.to_h,
    }.to_json
  end
  let(:pending_subscription) { create(:subscription, id: '456', status: 'pending') }
  let(:response_with_pending) do
    {
      'subscription' => pending_subscription.to_h,
    }.to_json
  end

  describe '#create' do
    let(:params) do
      {
        external_customer_id: factory_subscription.external_customer_id,
        plan_code: factory_subscription.plan_code,
        external_id: factory_subscription.external_id,
        subscription_at: factory_subscription.subscription_at,
        billing_time: factory_subscription.billing_time,
        ending_at: factory_subscription.ending_at,
        plan_overrides: {
          amount_cents: 1000,
          minimum_commitment: {
            amount_cents: 2000,
            invoice_display_name: 'Minimum commitment (C1)',
          },
        },
      }
    end
    let(:body) do
      {
        'subscription' => params,
      }
    end

    context 'when subscription is successfully changed' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/subscriptions')
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns subscription' do
        subscription = resource.create(params)

        expect(subscription.external_customer_id).to eq(factory_subscription.external_customer_id)
        expect(subscription.plan_code).to eq(factory_subscription.plan_code)
        expect(subscription.plan_amount_cents).to eq(factory_subscription.plan_amount_cents)
        expect(subscription.plan_amount_currency).to eq(factory_subscription.plan_amount_currency)
        expect(subscription.status).to eq(factory_subscription.status)
        expect(subscription.external_id).to eq(factory_subscription.external_id)
        expect(subscription.subscription_at).to eq(factory_subscription.subscription_at)
        expect(subscription.billing_time).to eq(factory_subscription.billing_time)
        expect(subscription.ending_at).to eq(factory_subscription.ending_at)
      end
    end

    context 'when subscription is NOT successfully changed' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/subscriptions')
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#delete' do
    context 'when subscription is successfully terminated' do
      before do
        stub_request(:delete, 'https://api.getlago.com/api/v1/subscriptions/123')
          .to_return(body: response, status: 200)
      end

      it 'returns subscription' do
        subscription = resource.destroy('123')

        expect(subscription.external_customer_id).to eq(factory_subscription.external_customer_id)
        expect(subscription.plan_code).to eq(factory_subscription.plan_code)
        expect(subscription.status).to eq(factory_subscription.status)
      end
    end

    context 'when subscription is pending' do
      before do
        stub_request(:delete, 'https://api.getlago.com/api/v1/subscriptions/456?status=pending')
          .to_return(body: response_with_pending, status: 200)
      end

      it 'returns subscription' do
        subscription = resource.destroy('456', options: { status: 'pending' })

        expect(subscription.external_customer_id).to eq(pending_subscription.external_customer_id)
        expect(subscription.plan_code).to eq(pending_subscription.plan_code)
        expect(subscription.status).to eq(pending_subscription.status)
      end
    end

    context 'when subscription is NOT successfully terminated' do
      before do
        stub_request(:delete, 'https://api.getlago.com/api/v1/subscriptions/123')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy('123') }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#update' do
    let(:params) { { name: 'new name' } }
    let(:body) do
      {
        'subscription' => params,
      }
    end

    context 'when subscription is successfully updated' do
      before do
        stub_request(:put, 'https://api.getlago.com/api/v1/subscriptions/123')
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns an subscription' do
        subscription = resource.update(params, '123')

        expect(subscription.external_customer_id).to eq(factory_subscription.external_customer_id)
        expect(subscription.plan_code).to eq(factory_subscription.plan_code)
        expect(subscription.status).to eq(factory_subscription.status)
        expect(subscription.external_id).to eq(factory_subscription.external_id)
      end
    end

    context 'when subscription failed to update' do
      before do
        stub_request(:put, 'https://api.getlago.com/api/v1/subscriptions/123')
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, '123') }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get' do
    context 'when subscription is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{factory_subscription.external_id}")
          .to_return(body: response, status: 200)
      end

      it 'returns a subscription' do
        subscription = resource.get(factory_subscription.external_id)

        expect(subscription.external_id).to eq(factory_subscription.external_id)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{factory_subscription.external_id}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get(factory_subscription.external_id) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:response) do
      {
        'subscriptions' => [
          factory_subscription.to_h,
        ],
        'meta': {
          'current_page' => 1,
          'next_page' => 2,
          'prev_page' => nil,
          'total_pages' => 7,
          'total_count' => 63,
        },
      }.to_json
    end

    context 'when external_customer_id is given' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/subscriptions?external_customer_id=123')
          .to_return(body: response, status: 200)
      end

      it 'returns subscriptions on selected page' do
        response = resource.get_all({ external_customer_id: '123' })

        expect(response['subscriptions'].first['lago_id']).to eq(factory_subscription.lago_id)
        expect(response['subscriptions'].first['external_id']).to eq(factory_subscription.external_id)
        expect(response['subscriptions'].first['plan_amount_cents']).to eq(factory_subscription.plan_amount_cents)
        expect(response['subscriptions'].first['plan_amount_currency']).to eq(factory_subscription.plan_amount_currency)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when status is given' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/subscriptions?external_customer_id=123&status%5B%5D=pending')
          .to_return(body: response, status: 200)

        create(:subscription, status: 'pending')
      end

      it 'returns subscriptions with that given status' do
        response = resource.get_all({ external_customer_id: '123', 'status[]': 'pending' })
        expect(response['subscriptions'].count).to eq(1)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/subscriptions')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#lifetime_usage' do
    let(:json_response) { load_fixture('subscription_lifetime_usage') }
    let(:lifetime_usage_response) { JSON.parse(json_response) }
    let(:external_subscription_id) { lifetime_usage_response['lifetime_usage']['external_subscription_id'] }

    context 'when lifetime usage is successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/lifetime_usage")
          .to_return(body: json_response, status: 200)
      end

      it 'returns lifetime usage' do
        lifetime_usage = resource.lifetime_usage(external_subscription_id)

        expect(lifetime_usage.external_subscription_id).to eq(external_subscription_id)
      end
    end

    context 'when lifetime usage is not found' do
      let(:not_found_response) do
        {
          'status' => 404,
          'error' => 'Not Found',
          'code' => 'credit_note_not_found',
        }.to_json
      end

      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/lifetime_usage")
          .to_return(body: not_found_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.lifetime_usage(external_subscription_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#update_lifetime_usage' do
    let(:params) { create(:update_lifetime_usage).to_h }

    let(:json_response) { load_fixture('subscription_lifetime_usage') }
    let(:lifetime_usage_response) { JSON.parse(json_response) }
    let(:external_subscription_id) { lifetime_usage_response['lifetime_usage']['external_subscription_id'] }

    before do
      stub_request(:put, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/lifetime_usage")
        .with(body: { lifetime_usage: params })
        .to_return(body: json_response, status: 200)
    end

    it 'returns lifetime usage' do
      lifetime_usage = resource.update_lifetime_usage(external_subscription_id, params)

      expect(lifetime_usage.external_subscription_id).to eq(external_subscription_id)
    end

    context 'when lifetime usage is not found' do
      let(:not_found_response) do
        {
          'status' => 404,
          'error' => 'Not Found',
          'code' => 'credit_note_not_found',
        }.to_json
      end

      before do
        stub_request(:put, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/lifetime_usage")
          .with(body: { lifetime_usage: params })
          .to_return(body: not_found_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.update_lifetime_usage(external_subscription_id, params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#get_alert' do
    let(:json_response) { load_fixture('subscription_alert') }
    let(:alert_response) { JSON.parse(json_response) }
    let(:external_subscription_id) { alert_response['alert']['external_subscription_id'] }
    let(:code) { alert_response['alert']['code'] }

    context 'when alert is successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/alerts/#{code}")
          .to_return(body: json_response, status: 200)
      end

      it 'returns alert' do
        alert = resource.get_alert(external_subscription_id, code)

        expect(alert.external_subscription_id).to eq(external_subscription_id)
        expect(alert.code).to eq(code)
      end
    end

    context 'when alert is not found' do
      let(:not_found_response) do
        {
          'status' => 404,
          'error' => 'Not Found',
          'code' => 'alert_not_found',
        }.to_json
      end

      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/alerts/#{code}")
          .to_return(body: not_found_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.get_alert(external_subscription_id, code) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#update_alert' do
    let(:params) do
      { name: 'Update name' }
    end
    let(:json_response) { load_fixture('subscription_alert') }
    let(:alert_response) { JSON.parse(json_response) }
    let(:external_subscription_id) { alert_response['alert']['external_subscription_id'] }
    let(:code) { alert_response['alert']['code'] }

    before do
      stub_request(:put, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/alerts/#{code}")
        .with(body: { alert: params })
        .to_return(body: json_response, status: 200)
    end

    it 'returns alert' do
      alert = resource.update_alert(external_subscription_id, code, params)

      expect(alert.external_subscription_id).to eq(external_subscription_id)
      expect(alert.code).to eq(code)
    end

    context 'when alert is not found' do
      let(:not_found_response) do
        {
          'status' => 404,
          'error' => 'Not Found',
          'code' => 'alert_not_found',
        }.to_json
      end

      before do
        stub_request(:put, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/alerts/#{code}")
          .with(body: { alert: params })
          .to_return(body: not_found_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.update_alert(external_subscription_id, code, params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#delete_alert' do
    let(:json_response) { load_fixture('subscription_alert') }
    let(:alert_response) { JSON.parse(json_response) }
    let(:external_subscription_id) { alert_response['alert']['external_subscription_id'] }
    let(:code) { alert_response['alert']['code'] }

    before do
      stub_request(:delete, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/alerts/#{code}")
        .to_return(body: json_response, status: 200)
    end

    it 'returns alert' do
      alert = resource.delete_alert(external_subscription_id, code)

      expect(alert.external_subscription_id).to eq(external_subscription_id)
      expect(alert.code).to eq(code)
    end

    context 'when alert is not found' do
      let(:not_found_response) do
        {
          'status' => 404,
          'error' => 'Not Found',
          'code' => 'alert_not_found',
        }.to_json
      end

      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/alerts/#{code}")
          .to_return(body: not_found_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.delete_alert(external_subscription_id, code) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#get_alerts' do
    let(:json_response) { load_fixture('subscription_alerts') }
    let(:alerts_response) { JSON.parse(json_response) }
    let(:external_subscription_id) { alerts_response['alerts'].first['external_subscription_id'] }

    context 'when alerts are successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/alerts")
          .to_return(body: json_response, status: 200)
      end

      it 'returns alerts' do
        alerts = resource.get_alerts(external_subscription_id)

        expect(alerts.first.external_subscription_id).to eq(external_subscription_id)
      end
    end

    context 'when alerts are not found' do
      let(:not_found_response) do
        {
          'status' => 404,
          'error' => 'Not Found',
          'code' => 'subscription_not_found',
        }.to_json
      end

      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/alerts")
          .to_return(body: not_found_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.get_alerts(external_subscription_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#create_alert' do
    let(:params) do
      JSON.parse(load_fixture('subscription_alert'), symbolize_names: true)[:alert].slice(
        :name,
        :code,
        :alert_type,
        :thresholds,
      )
    end
    let(:json_response) { load_fixture('subscription_alert') }
    let(:alert_response) { JSON.parse(json_response) }
    let(:external_subscription_id) { alert_response['alert']['external_subscription_id'] }

    before do
      stub_request(:post, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/alerts")
        .with(body: { alert: params })
        .to_return(body: json_response, status: 200)
    end

    it 'returns alert' do
      alert = resource.create_alert(external_subscription_id, params)

      expect(alert.external_subscription_id).to eq(external_subscription_id)
      expect(alert.code).to eq(params[:code])
    end

    context 'when alert creation fails' do
      let(:error_response) do
        {
          'status' => 422,
          'error' => 'Unprocessable Entity',
          'message' => 'Validation error on the record',
        }.to_json
      end

      before do
        stub_request(:post, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/alerts")
          .with(body: { alert: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create_alert(external_subscription_id, params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#create_alerts' do
    let(:json_response) { load_fixture('subscription_alerts') }
    let(:alerts_response) { JSON.parse(json_response) }
    let(:external_subscription_id) { alerts_response['alerts'].first['external_subscription_id'] }
    let(:params) do
      {
        alerts: [
          {
            code: 'alert1',
            name: 'First Alert',
            alert_type: 'current_usage_amount',
            thresholds: [{ code: 'warn', value: 1000 }],
          },
          {
            code: 'alert2',
            alert_type: 'billable_metric_current_usage_amount',
            billable_metric_code: 'storage',
            thresholds: [{ value: 2000 }],
          },
        ],
      }
    end

    context 'when alerts are successfully created' do
      before do
        stub_request(:post, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/alerts")
          .with(body: params)
          .to_return(body: json_response, status: 200)
      end

      it 'returns alerts' do
        alerts = resource.create_alerts(external_subscription_id, params)

        expect(alerts.count).to eq(2)
        expect(alerts.first.external_subscription_id).to eq(external_subscription_id)
      end
    end

    context 'when alert creation fails' do
      let(:error_response) do
        {
          'status' => 422,
          'error' => 'Unprocessable Entity',
          'message' => 'Validation error on the record',
        }.to_json
      end

      before do
        stub_request(:post, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/alerts")
          .with(body: params)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create_alerts(external_subscription_id, params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#delete_alerts' do
    let(:external_subscription_id) { 'sub-12345' }

    context 'when alerts are successfully deleted' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/alerts")
          .to_return(body: '', status: 200)
      end

      it 'does not raise an error' do
        expect { resource.delete_alerts(external_subscription_id) }.not_to raise_error
      end
    end

    context 'when subscription is not found' do
      let(:not_found_response) do
        {
          'status' => 404,
          'error' => 'Not Found',
          'code' => 'subscription_not_found',
        }.to_json
      end

      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/alerts")
          .to_return(body: not_found_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.delete_alerts(external_subscription_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  # Charges

  describe '#get_all_charges' do
    let(:json_response) { load_fixture('subscription_charges') }
    let(:external_subscription_id) { 'sub_123' }

    context 'when charges are successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/charges")
          .to_return(body: json_response, status: 200)
      end

      it 'returns charges with meta' do
        response = resource.get_all_charges(external_subscription_id)

        expect(response['charges'].first['lago_id']).to eq('51c1e851-5be6-4343-a0ee-39a81d8b4ee1')
        expect(response['charges'].first['code']).to eq('charge_code')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/charges")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all_charges(external_subscription_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#get_charge' do
    let(:json_response) { load_fixture('subscription_charge') }
    let(:external_subscription_id) { 'sub_123' }
    let(:charge_code) { 'charge_code' }

    context 'when charge is successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/charges/#{charge_code}")
          .to_return(body: json_response, status: 200)
      end

      it 'returns charge' do
        charge = resource.get_charge(external_subscription_id, charge_code)

        expect(charge.lago_id).to eq('51c1e851-5be6-4343-a0ee-39a81d8b4ee1')
        expect(charge.code).to eq(charge_code)
      end
    end

    context 'when charge is not found' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/charges/#{charge_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_charge(external_subscription_id, charge_code) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#update_charge' do
    let(:json_response) { load_fixture('subscription_charge') }
    let(:external_subscription_id) { 'sub_123' }
    let(:charge_code) { 'charge_code' }
    let(:params) { { invoice_display_name: 'Updated Setup' } }

    context 'when charge is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/charges/#{charge_code}")
          .with(body: { charge: params })
          .to_return(body: json_response, status: 200)
      end

      it 'returns charge' do
        charge = resource.update_charge(external_subscription_id, charge_code, params)

        expect(charge.lago_id).to eq('51c1e851-5be6-4343-a0ee-39a81d8b4ee1')
        expect(charge.code).to eq(charge_code)
      end
    end

    context 'when charge update fails' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/charges/#{charge_code}")
          .with(body: { charge: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect do
          resource.update_charge(external_subscription_id, charge_code, params)
        end.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  # Fixed Charges

  describe '#get_all_fixed_charges' do
    let(:json_response) { load_fixture('subscription_fixed_charges') }
    let(:external_subscription_id) { 'sub_123' }

    context 'when fixed charges are successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/fixed_charges")
          .to_return(body: json_response, status: 200)
      end

      it 'returns fixed charges with meta' do
        response = resource.get_all_fixed_charges(external_subscription_id)

        expect(response['fixed_charges'].first['lago_id']).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
        expect(response['fixed_charges'].first['charge_model']).to eq('standard')
        expect(response['fixed_charges'].first['invoice_display_name']).to eq('Setup Fee')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when subscription is not found' do
      let(:not_found_response) do
        {
          'status' => 404,
          'error' => 'Not Found',
          'code' => 'subscription_not_found',
        }.to_json
      end

      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/fixed_charges")
          .to_return(body: not_found_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.get_all_fixed_charges(external_subscription_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#get_fixed_charge' do
    let(:json_response) { load_fixture('subscription_fixed_charge') }
    let(:external_subscription_id) { 'sub_123' }
    let(:fixed_charge_code) { 'fixed_setup' }

    context 'when fixed charge is successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/fixed_charges/#{fixed_charge_code}")
          .to_return(body: json_response, status: 200)
      end

      it 'returns fixed charge' do
        fixed_charge = resource.get_fixed_charge(external_subscription_id, fixed_charge_code)

        expect(fixed_charge.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
        expect(fixed_charge.code).to eq(fixed_charge_code)
      end
    end

    context 'when fixed charge is not found' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/fixed_charges/#{fixed_charge_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect do
          resource.get_fixed_charge(external_subscription_id, fixed_charge_code)
        end.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#update_fixed_charge' do
    let(:json_response) { load_fixture('subscription_fixed_charge') }
    let(:external_subscription_id) { 'sub_123' }
    let(:fixed_charge_code) { 'fixed_setup' }
    let(:params) { { invoice_display_name: 'Updated Setup Fee' } }

    context 'when fixed charge is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/fixed_charges/#{fixed_charge_code}")
          .with(body: { fixed_charge: params })
          .to_return(body: json_response, status: 200)
      end

      it 'returns fixed charge' do
        fixed_charge = resource.update_fixed_charge(external_subscription_id, fixed_charge_code, params)

        expect(fixed_charge.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
        expect(fixed_charge.code).to eq(fixed_charge_code)
      end
    end

    context 'when fixed charge update fails' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/fixed_charges/#{fixed_charge_code}")
          .with(body: { fixed_charge: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect do
          resource.update_fixed_charge(external_subscription_id, fixed_charge_code, params)
        end.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  # Charge Filters

  describe '#get_all_charge_filters' do
    let(:json_response) { load_fixture('subscription_charge_filters') }
    let(:external_subscription_id) { 'sub_123' }
    let(:charge_code) { 'charge_code' }

    context 'when charge filters are successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/charges/#{charge_code}/filters")
          .to_return(body: json_response, status: 200)
      end

      it 'returns filters with meta' do
        response = resource.get_all_charge_filters(external_subscription_id, charge_code)

        expect(response['filters'].first['lago_id']).to eq('f1901a90-1a90-1a90-1a90-1a901a901a90')
        expect(response['filters'].first['invoice_display_name']).to eq('From France')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/charges/#{charge_code}/filters")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect do
          resource.get_all_charge_filters(external_subscription_id, charge_code)
        end.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#get_charge_filter' do
    let(:json_response) { load_fixture('subscription_charge_filter') }
    let(:external_subscription_id) { 'sub_123' }
    let(:charge_code) { 'charge_code' }
    let(:filter_id) { 'f1901a90-1a90-1a90-1a90-1a901a901a90' }

    context 'when charge filter is successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/charges/#{charge_code}/filters/#{filter_id}")
          .to_return(body: json_response, status: 200)
      end

      it 'returns filter' do
        filter = resource.get_charge_filter(external_subscription_id, charge_code, filter_id)

        expect(filter.lago_id).to eq(filter_id)
        expect(filter.invoice_display_name).to eq('From France')
      end
    end

    context 'when charge filter is not found' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/charges/#{charge_code}/filters/#{filter_id}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect do
          resource.get_charge_filter(external_subscription_id, charge_code, filter_id)
        end.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#create_charge_filter' do
    let(:json_response) { load_fixture('subscription_charge_filter') }
    let(:external_subscription_id) { 'sub_123' }
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
        stub_request(:post, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/charges/#{charge_code}/filters")
          .with(body: { filter: params })
          .to_return(body: json_response, status: 200)
      end

      it 'returns filter' do
        filter = resource.create_charge_filter(external_subscription_id, charge_code, params)

        expect(filter.lago_id).to eq('f1901a90-1a90-1a90-1a90-1a901a901a90')
        expect(filter.invoice_display_name).to eq('From France')
      end
    end

    context 'when charge filter creation fails' do
      before do
        stub_request(:post, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/charges/#{charge_code}/filters")
          .with(body: { filter: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect do
          resource.create_charge_filter(external_subscription_id, charge_code, params)
        end.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#update_charge_filter' do
    let(:json_response) { load_fixture('subscription_charge_filter') }
    let(:external_subscription_id) { 'sub_123' }
    let(:charge_code) { 'charge_code' }
    let(:filter_id) { 'f1901a90-1a90-1a90-1a90-1a901a901a90' }
    let(:params) { { invoice_display_name: 'Updated Filter' } }

    context 'when charge filter is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/charges/#{charge_code}/filters/#{filter_id}")
          .with(body: { filter: params })
          .to_return(body: json_response, status: 200)
      end

      it 'returns filter' do
        filter = resource.update_charge_filter(external_subscription_id, charge_code, filter_id, params)

        expect(filter.lago_id).to eq(filter_id)
        expect(filter.invoice_display_name).to eq('From France')
      end
    end

    context 'when charge filter update fails' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/charges/#{charge_code}/filters/#{filter_id}")
          .with(body: { filter: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect do
          resource.update_charge_filter(external_subscription_id, charge_code, filter_id, params)
        end.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#destroy_charge_filter' do
    let(:json_response) { load_fixture('subscription_charge_filter') }
    let(:external_subscription_id) { 'sub_123' }
    let(:charge_code) { 'charge_code' }
    let(:filter_id) { 'f1901a90-1a90-1a90-1a90-1a901a901a90' }

    context 'when charge filter is successfully destroyed' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/charges/#{charge_code}/filters/#{filter_id}")
          .to_return(body: json_response, status: 200)
      end

      it 'returns filter' do
        filter = resource.destroy_charge_filter(external_subscription_id, charge_code, filter_id)

        expect(filter.lago_id).to eq(filter_id)
        expect(filter.invoice_display_name).to eq('From France')
      end
    end

    context 'when charge filter destruction fails' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/charges/#{charge_code}/filters/#{filter_id}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect do
          resource.destroy_charge_filter(external_subscription_id, charge_code, filter_id)
        end.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#get_entitlements' do
    let(:json_response) { load_fixture('subscription_entitlements') }
    let(:entitlements_response) { JSON.parse(json_response) }
    let(:external_subscription_id) { 'sub_123' }

    context 'when entitlements are successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/entitlements")
          .to_return(body: json_response, status: 200)
      end

      it 'returns entitlements' do
        entitlements = resource.get_entitlements(external_subscription_id)

        expect(entitlements).to be_an(Array)
        expect(entitlements.map(&:code)).to eq %w[seats analytics_api salesforce sso]
      end
    end

    context 'when entitlements are not found' do
      let(:not_found_response) do
        {
          'status' => 404,
          'error' => 'Not Found',
          'code' => 'subscription_not_found',
        }.to_json
      end

      before do
        stub_request(:get, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/entitlements")
          .to_return(body: not_found_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.get_entitlements(external_subscription_id) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#delete_entitlement' do
    let(:external_subscription_id) { 'sub_123' }
    let(:feature_code) { 'seats' }
    let(:response_body) { { worked: true }.to_json }

    context 'when entitlement is successfully deleted' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/entitlements/#{feature_code}")
          .to_return(body: response_body, status: 200)
      end

      it 'returns response' do
        response = resource.delete_entitlement(external_subscription_id, feature_code)

        expect(response.worked).to be true
      end
    end
  end

  describe '#update_entitlements' do
    let(:external_subscription_id) { 'sub_123' }
    let(:params) do
      {
        seats: {
          root: true,
        },
      }
    end
    let(:response_body) { { worked: true }.to_json }

    context 'when entitlements are successfully updated' do
      before do
        stub_request(:patch, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/entitlements")
          .with(body: { entitlements: params })
          .to_return(body: response_body, status: 200)
      end

      it 'returns response' do
        response = resource.update_entitlements(external_subscription_id, params)

        expect(response.worked).to be true
      end
    end
  end

  describe '#delete_entitlement_privilege' do
    let(:external_subscription_id) { 'sub_123' }
    let(:entitlement_code) { 'seats' }
    let(:privilege_code) { 'max_admins' }
    let(:response_body) { { worked: true }.to_json }

    context 'when entitlement privilege is successfully deleted' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/subscriptions/#{external_subscription_id}/entitlements/#{entitlement_code}/privileges/#{privilege_code}")
          .to_return(body: response_body, status: 200)
      end

      it 'returns response' do
        response = resource.delete_entitlement_privilege(external_subscription_id, entitlement_code, privilege_code)

        expect(response.worked).to be true
      end
    end
  end
end
