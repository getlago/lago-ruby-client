# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#subscriptions', :integration do
  let(:customer) { create_customer(presets: [:french]) }
  let(:plan) { create_plan }

  describe '#create' do
    it 'creates a subscription', :aggregate_failures do
      subscription = create_subscription(
        external_customer_id: customer.external_id,
        plan_code: plan.code,
      )

      expect(subscription).to have_attributes(
        plan_code: plan.code,
        external_customer_id: customer.external_id,
        status: 'active',
        billing_time: 'calendar',
      )
      expect(subscription.external_id).to be_present
      expect(subscription.created_at).to be_present
      expect(subscription.started_at).to be_present
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

      expect(updated_subscription).to have_attributes(
        name: updated_name,
        external_id: subscription.external_id,
      )
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
