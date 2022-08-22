# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Subscription do
  subject(:resource) { described_class.new(client) }
  let(:client) { Lago::Api::Client.new }
  let(:factory_subscription) { FactoryBot.build(:subscription) }
  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record'
    }.to_json
  end
  let(:response) do
    {
      'subscription' => factory_subscription.to_h
    }.to_json
  end

  describe '#create' do
    let(:params) do
      {
        customer_id: factory_subscription.customer_id,
        plan_code: factory_subscription.plan_code,
        unique_id: factory_subscription.unique_id,
        subscription_id: factory_subscription.subscription_id,
        billing_time: factory_subscription.billing_time
      }
    end
    let(:body) do
      {
        'subscription' => params
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

        expect(subscription.customer_id).to eq(factory_subscription.customer_id)
        expect(subscription.plan_code).to eq(factory_subscription.plan_code)
        expect(subscription.status).to eq(factory_subscription.status)
        expect(subscription.unique_id).to eq(factory_subscription.unique_id)
        expect(subscription.billing_time).to eq(factory_subscription.billing_time)
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

        expect(subscription.customer_id).to eq(factory_subscription.customer_id)
        expect(subscription.plan_code).to eq(factory_subscription.plan_code)
        expect(subscription.status).to eq(factory_subscription.status)
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
        'subscription' => params
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

        expect(subscription.customer_id).to eq(factory_subscription.customer_id)
        expect(subscription.plan_code).to eq(factory_subscription.plan_code)
        expect(subscription.status).to eq(factory_subscription.status)
        expect(subscription.unique_id).to eq(factory_subscription.unique_id)
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

  describe '#get_all' do
    let(:response) do
      {
        'subscriptions' => [
          factory_subscription.to_h
        ],
        'meta': {
          'current_page' => 1,
          'next_page' => 2,
          'prev_page' => nil,
          'total_pages' => 7,
          'total_count' => 63
        }
      }.to_json
    end

    context 'when customer_id is given' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/subscriptions?customer_id=123')
          .to_return(body: response, status: 200)
      end

      it 'returns subscriptions on selected page' do
        response = resource.get_all({ customer_id: '123' })

        expect(response['subscriptions'].first['lago_id']).to eq(factory_subscription.lago_id)
        expect(response['subscriptions'].first['unique_id']).to eq(factory_subscription.unique_id)
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
end
