# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#subscriptions', :integration do
  let(:customer) { create_customer(presets: [:french]) }
  let(:plan) { create_plan }

  describe '#create' do
    it 'creates a subscription' do
      subscription = create_subscription(
        external_customer_id: customer.external_id,
        plan_code: plan.code,
      )

      expect(subscription.external_id).to be_present
      expect(subscription.plan_code).to eq(plan.code)
      expect(subscription.external_customer_id).to eq(customer.external_id)
      expect(subscription.status).to eq('active')
      expect(subscription.created_at).to be_present
      expect(subscription.started_at).to be_present
      expect(subscription.billing_time).to eq('calendar')
    end

    context 'when payment_method is invalid' do
      it 'raises an error' do
        expect {
          create_subscription(
            external_customer_id: customer.external_id,
            plan_code: plan.code,
            params: {
              payment_method: {
                payment_method_type: 'invalid_type',
                payment_method_id: 'invalid-id',
              },
            },
          )
        }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#update' do
    let(:subscription) do
      create_subscription(
        external_customer_id: customer.external_id,
        plan_code: plan.code,
      )
    end
    let(:updated_name) { 'Updated Subscription' }

    it 'updates the subscription' do
      updated_subscription = client.subscriptions.update({ name: updated_name }, subscription.external_id)

      expect(updated_subscription.name).to eq(updated_name)
      expect(updated_subscription.external_id).to eq(subscription.external_id)
    end

    context 'when payment_method is invalid' do
      it 'raises an error' do
        expect {
          client.subscriptions.update(
            {
              payment_method: {
                payment_method_type: 'invalid_type',
                payment_method_id: 'invalid-id',
              },
            },
            subscription.external_id,
          )
        }.to raise_error(Lago::Api::HttpError)
      end
    end
  end
end
