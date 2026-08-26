# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Order do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:order_response) { load_fixture('order') }
  let(:order_id) { JSON.parse(order_response)['order']['lago_id'] }
  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#get' do
    let(:endpoint) { "https://api.getlago.com/api/v1/orders/#{order_id}" }

    context 'when order is successfully fetched' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: order_response, status: 200)
      end

      it 'returns an order' do
        order = resource.get(order_id)

        expect(order.lago_id).to eq(order_id)
        expect(order.number).to eq('OR-2026-0001')
        expect(order.status).to eq('created')
        expect(order.order_type).to eq('subscription_creation')
        expect(order.execution_mode).to eq('execute_in_lago')
        expect(order.executed_at).to be_nil
        expect(order.execution_record.errors).to eq([])
        expect(order.lago_order_form_id).to eq('aa11aa11-aa11-aa11-aa11-aa11aa11aa11')
        expect(order.billing_snapshot.plans.first.payload.code).to eq('premium_plan')
      end
    end

    context 'when is not found' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: { 'status' => 404, 'error' => 'Not Found' }.to_json, status: 404)
      end

      it 'raises an error' do
        expect { resource.get(order_id) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:endpoint) { "https://api.getlago.com/api/v1/orders#{options}" }
    let(:options) { '' }
    let(:orders_response) { load_fixture('orders_index') }

    context 'when there is no options' do
      before do
        stub_request(:get, endpoint)
          .to_return(body: orders_response, status: 200)
      end

      it 'returns orders on the first page' do
        response = resource.get_all

        expect(response['orders'].first['number']).to eq('OR-2026-0001')
        expect(response['orders'].last['status']).to eq('failed')
        expect(response['orders'].last['execution_mode']).to be_nil
        expect(response['orders'].last['execution_record']['errors']).to eq(['plan_not_found'])
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      let(:options_hash) do
        { per_page: 2, page: 1, 'status[]' => 'created', 'execution_mode[]' => 'execute_in_lago' }
      end
      let(:options) { "?#{URI.encode_www_form(options_hash)}" }

      before do
        stub_request(:get, endpoint)
          .to_return(body: orders_response, status: 200)
      end

      it 'returns orders on the selected page' do
        response = resource.get_all(options_hash)

        expect(response['orders'].first['number']).to eq('OR-2026-0001')
        expect(response['meta']['current_page']).to eq(1)
      end
    end
  end

  describe '#execute' do
    let(:endpoint) { "https://api.getlago.com/api/v1/orders/#{order_id}/execute" }
    let(:executed_response) { load_fixture('executed_order') }

    context 'when no params are given' do
      before do
        stub_request(:post, endpoint)
          .with(body: {})
          .to_return(body: executed_response, status: 200)
      end

      it 'returns the executed order' do
        order = resource.execute(order_id)

        expect(order.lago_id).to eq(order_id)
        expect(order.status).to eq('executed')
        expect(order.executed_at).to eq('2026-07-01T00:00:00Z')
        expect(order.execution_record.subscription_ids).to eq(['dd44dd44-dd44-dd44-dd44-dd44dd44dd44'])
        expect(order.execution_record.applied_coupon_ids).to eq(['ee55ee55-ee55-ee55-ee55-ee55ee55ee55'])
      end
    end

    context 'when an execution mode is given' do
      let(:params) { { execution_mode: 'execute_in_lago' } }

      before do
        stub_request(:post, endpoint)
          .with(body: { order: params })
          .to_return(body: executed_response, status: 200)
      end

      it 'returns the executed order' do
        order = resource.execute(order_id, params)

        expect(order.status).to eq('executed')
      end
    end

    context 'when the order cannot be executed' do
      before do
        stub_request(:post, endpoint)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.execute(order_id) }.to raise_error Lago::Api::HttpError
      end
    end

    context 'when a catalog record pinned by the quote is missing' do
      before do
        stub_request(:post, endpoint)
          .to_return(body: { 'status' => 404, 'error' => 'Not Found' }.to_json, status: 404)
      end

      it 'raises an error' do
        expect { resource.execute(order_id) }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
