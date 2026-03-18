# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Customers::Wallets::Alert do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:customer_id) { 'customer-id' }
  let(:wallet_code) { 'wallet-code' }

  describe '#create' do
    let(:params) do
      JSON.parse(load_fixture('wallet_alert'), symbolize_names: true)[:alert].slice(
        :name,
        :code,
        :alert_type,
        :thresholds,
      )
    end
    let(:json_response) { load_fixture('wallet_alert') }
    let(:alert_response) { JSON.parse(json_response) }
    let(:customer_id) { alert_response['alert']['external_customer_id'] }
    let(:wallet_code) { alert_response['alert']['wallet_code'] }

    before do
      stub_request(:post, "https://api.getlago.com/api/v1/customers/#{customer_id}/wallets/#{wallet_code}/alerts")
        .with(body: { alert: params })
        .to_return(body: json_response, status: 200)
    end

    it 'returns alert' do
      alert = resource.create(customer_id, wallet_code, params)

      expect(alert.external_customer_id).to eq(customer_id)
      expect(alert.wallet_code).to eq(wallet_code)
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
        stub_request(:post, "https://api.getlago.com/api/v1/customers/#{customer_id}/wallets/#{wallet_code}/alerts")
          .with(body: { alert: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(customer_id, wallet_code, params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#get' do
    let(:json_response) { load_fixture('wallet_alert') }
    let(:alert_response) { JSON.parse(json_response) }
    let(:customer_id) { alert_response['alert']['external_customer_id'] }
    let(:wallet_code) { alert_response['alert']['wallet_code'] }
    let(:code) { alert_response['alert']['code'] }

    context 'when alert is successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{customer_id}/wallets/#{wallet_code}/alerts/#{code}")
          .to_return(body: json_response, status: 200)
      end

      it 'returns alert' do
        alert = resource.get(customer_id, wallet_code, code)

        expect(alert.external_customer_id).to eq(customer_id)
        expect(alert.wallet_code).to eq(wallet_code)
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
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{customer_id}/wallets/#{wallet_code}/alerts/#{code}")
          .to_return(body: not_found_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.get(customer_id, wallet_code, code) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#update' do
    let(:params) do
      { name: 'Update name' }
    end
    let(:json_response) { load_fixture('wallet_alert') }
    let(:alert_response) { JSON.parse(json_response) }
    let(:customer_id) { alert_response['alert']['external_customer_id'] }
    let(:wallet_code) { alert_response['alert']['wallet_code'] }
    let(:code) { alert_response['alert']['code'] }

    before do
      stub_request(:put, "https://api.getlago.com/api/v1/customers/#{customer_id}/wallets/#{wallet_code}/alerts/#{code}")
        .with(body: { alert: params })
        .to_return(body: json_response, status: 200)
    end

    it 'returns alert' do
      alert = resource.update(customer_id, wallet_code, code, params)

      expect(alert.external_customer_id).to eq(customer_id)
      expect(alert.wallet_code).to eq(wallet_code)
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
        stub_request(:put, "https://api.getlago.com/api/v1/customers/#{customer_id}/wallets/#{wallet_code}/alerts/#{code}")
          .with(body: { alert: params })
          .to_return(body: not_found_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.update(customer_id, wallet_code, code, params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#destroy' do
    let(:json_response) { load_fixture('wallet_alert') }
    let(:alert_response) { JSON.parse(json_response) }
    let(:customer_id) { alert_response['alert']['external_customer_id'] }
    let(:wallet_code) { alert_response['alert']['wallet_code'] }
    let(:code) { alert_response['alert']['code'] }

    before do
      stub_request(:delete, "https://api.getlago.com/api/v1/customers/#{customer_id}/wallets/#{wallet_code}/alerts/#{code}")
        .to_return(body: json_response, status: 200)
    end

    it 'returns alert' do
      alert = resource.destroy(customer_id, wallet_code, code)

      expect(alert.external_customer_id).to eq(customer_id)
      expect(alert.wallet_code).to eq(wallet_code)
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
        stub_request(:delete, "https://api.getlago.com/api/v1/customers/#{customer_id}/wallets/#{wallet_code}/alerts/#{code}")
          .to_return(body: not_found_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.destroy(customer_id, wallet_code, code) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#get_all' do
    let(:json_response) { load_fixture('wallet_alerts') }
    let(:alerts_response) { JSON.parse(json_response) }
    let(:customer_id) { alerts_response['alerts'].first['external_customer_id'] }
    let(:wallet_code) { alerts_response['alerts'].first['wallet_code'] }

    context 'when alerts are successfully retrieved' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{customer_id}/wallets/#{wallet_code}/alerts")
          .to_return(body: json_response, status: 200)
      end

      it 'returns alerts' do
        alerts = resource.get_all(customer_id, wallet_code).alerts

        expect(alerts).to contain_exactly(
          have_attributes(
            external_customer_id: customer_id,
            wallet_code:,
            code: 'wallet_balance_alert',
          ),
          have_attributes(external_customer_id: customer_id, wallet_code:, code: 'wallet_credits_alert'),
        )
      end
    end

    context 'when alerts are not found' do
      let(:not_found_response) do
        {
          'status' => 404,
          'error' => 'Not Found',
          'code' => 'wallet_not_found',
        }.to_json
      end

      before do
        stub_request(:get, "https://api.getlago.com/api/v1/customers/#{customer_id}/wallets/#{wallet_code}/alerts")
          .to_return(body: not_found_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.get_all(customer_id, wallet_code) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#create_batch' do
    let(:json_response) { load_fixture('wallet_alerts') }
    let(:alerts_response) { JSON.parse(json_response) }
    let(:customer_id) { alerts_response['alerts'].first['external_customer_id'] }
    let(:wallet_code) { alerts_response['alerts'].first['wallet_code'] }

    let(:params) do
      [
        {
          code: 'wallet_balance_alert',
          name: 'Wallet Balance Alert',
          alert_type: 'wallet_balance_amount',
          thresholds: [{ code: 'warn', value: 1000 }],
        },
        {
          code: 'wallet_credits_alert',
          name: 'Wallet Credits Alert',
          alert_type: 'wallet_credits_balance',
          thresholds: [{ value: 2000 }],
        },
      ]
    end

    context 'when alerts are successfully created' do
      before do
        stub_request(:post, "https://api.getlago.com/api/v1/customers/#{customer_id}/wallets/#{wallet_code}/alerts")
          .with(body: { alerts: params })
          .to_return(body: json_response, status: 200)
      end

      context 'when params are in form of an array' do
        it 'returns alerts' do
          alerts = resource.create_batch(customer_id, wallet_code, params)

          expect(alerts).to contain_exactly(
            have_attributes(
              external_customer_id: customer_id,
              wallet_code:,
              code: 'wallet_balance_alert',
            ),
            have_attributes(external_customer_id: customer_id, wallet_code:, code: 'wallet_credits_alert'),
          )
        end
      end

      context 'when params are in form of a hash' do
        it 'returns alerts' do
          alerts = resource.create_batch(customer_id, wallet_code, { alerts: params })

          expect(alerts).to contain_exactly(
            have_attributes(
              external_customer_id: customer_id,
              wallet_code:,
              code: 'wallet_balance_alert',
            ),
            have_attributes(external_customer_id: customer_id, wallet_code:, code: 'wallet_credits_alert'),
          )
        end
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
        stub_request(:post, "https://api.getlago.com/api/v1/customers/#{customer_id}/wallets/#{wallet_code}/alerts")
          .with(body: { alerts: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create_batch(customer_id, wallet_code, params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#destroy_all' do
    let(:json_response) { load_fixture('wallet_alert') }
    let(:alert_response) { JSON.parse(json_response) }
    let(:customer_id) { alert_response['alert']['external_customer_id'] }
    let(:wallet_code) { alert_response['alert']['wallet_code'] }

    context 'when alerts are successfully deleted' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/customers/#{customer_id}/wallets/#{wallet_code}/alerts")
          .to_return(body: json_response, status: 200)
      end

      it 'sends a request and returns nil' do
        response = resource.destroy_all(customer_id, wallet_code)
        expect(response).to be_nil
      end
    end

    context 'when an error occurs' do
      let(:not_found_response) do
        {
          'status' => 404,
          'error' => 'Not Found',
          'code' => 'wallet_not_found',
        }.to_json
      end

      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/customers/#{customer_id}/wallets/#{wallet_code}/alerts")
          .to_return(body: not_found_response, status: 404)
      end

      it 'raises an error' do
        expect { resource.destroy_all(customer_id, wallet_code) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end
end
