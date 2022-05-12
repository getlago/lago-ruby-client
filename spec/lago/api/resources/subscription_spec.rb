# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Subscription do
  subject(:resource) { described_class.new(client) }
  let(:client) { Lago::Api::Client.new }
  let(:factory_subscription) { FactoryBot.build(:subscription) }

  describe '#create' do
    let(:params) do
      {
        customer_id: factory_subscription.customer_id,
        plan_code: factory_subscription.plan_code
      }
    end
    let(:body) do
      {
        'subscription' => params
      }
    end

    context 'when subscription is successfully changed' do
      let(:response) do
        {
          'subscription' => factory_subscription.to_h
        }.to_json
      end
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/subscriptions')
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns subscription' do
        subscription = resource.create(params)

        expect(subscription.customer_id).to eq(factory_subscription.customer_id)
        expect(subscription.plan_code).to eq(factory_subscription.plan_code)
        expect(subscription.status).to eq(factory_subscription.status)
      end
    end

    context 'when subscription is NOT successfully changed' do
      let(:response) do
        {
          'status' => 422,
          'error' => 'Unprocessable Entity',
          'message' => 'Validation error on the record'
        }.to_json
      end

      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/subscriptions')
          .with(body: body)
          .to_return(body: response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#delete' do
    let(:params) { { 'customer_id' => factory_subscription.customer_id } }

    context 'when subscription is successfully terminated' do
      let(:response) do
        {
          'subscription' => factory_subscription.to_h
        }.to_json
      end

      before do
        stub_request(:delete, 'https://api.getlago.com/api/v1/subscriptions')
          .with(body: params)
          .to_return(body: response, status: 200)
      end

      it 'returns subscription' do
        subscription = resource.delete(params)

        expect(subscription.customer_id).to eq(factory_subscription.customer_id)
        expect(subscription.plan_code).to eq(factory_subscription.plan_code)
        expect(subscription.status).to eq(factory_subscription.status)
      end
    end

    context 'when subscription is NOT successfully terminated' do
      let(:response) do
        {
          'status' => 422,
          'error' => 'Unprocessable Entity',
          'message' => 'Validation error on the record'
        }.to_json
      end

      before do
        stub_request(:delete, 'https://api.getlago.com/api/v1/subscriptions')
          .with(body: params)
          .to_return(body: response, status: 422)
      end

      it 'raises an error' do
        expect { resource.delete(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
