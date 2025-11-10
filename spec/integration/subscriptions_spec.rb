# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#subscriptions', :integration do
  describe '#create' do
    before_all_integration_tests do
      @customer = create_customer(presets: [:us])
      @plan = client.plans.create(
        name: "Test Plan #{customer_unique_id}",
        code: "test-plan-#{customer_unique_id}",
        interval: 'monthly',
        amount_cents: 1000,
        amount_currency: 'USD',
        pay_in_advance: false,
      )
    end

    attr_reader :customer, :plan

    def customer_unique_id
      super(customer)
    end

    it 'creates a subscription' do
      subscription = client.subscriptions.create(
        external_id: "sub-#{customer_unique_id}",
        external_customer_id: customer.external_id,
        plan_code: plan.code,
      )

      expect(subscription.billing_time).to eq 'calendar'
      expect(subscription.canceled_at).to eq nil
      expect(subscription.created_at).to be_present
      expect(subscription.current_billing_period_ending_at).to be_present
      expect(subscription.current_billing_period_started_at).to be_present
      expect(subscription.downgrade_plan_date).to eq nil
      expect(subscription.ending_at).to eq nil
      expect(subscription.external_customer_id).to eq customer.external_id
      expect(subscription.external_id).to eq "sub-#{customer_unique_id}"
      expect(subscription.lago_customer_id).to eq customer.lago_id
      expect(subscription.lago_id).to be_present
      expect(subscription.name).to eq ''
      expect(subscription.next_plan_code).to eq nil
      expect(subscription.on_termination_credit_note).to eq nil
      expect(subscription.on_termination_invoice).to eq 'generate'
      expect(subscription.plan_code).to eq plan.code
      expect(subscription.previous_plan_code).to eq nil
      expect(subscription.started_at).to be_present
      expect(subscription.status).to eq 'active'
      expect(subscription.subscription_at).to be_present
      expect(subscription.terminated_at).to eq nil
      expect(subscription.trial_ended_at).to eq nil

      sub_plan = subscription.plan
      expect(sub_plan.active_subscriptions_count).to eq 0
      expect(sub_plan.amount_cents).to eq 1000
      expect(sub_plan.amount_currency).to eq 'USD'
      expect(sub_plan.bill_charges_monthly).to eq nil
      expect(sub_plan.bill_fixed_charges_monthly).to eq nil
      expect(sub_plan.charges).to eq []
      expect(sub_plan.code).to eq plan.code
      expect(sub_plan.created_at).to be_present
      expect(sub_plan.customers_count).to eq 0
      expect(sub_plan.description).to eq nil
      expect(sub_plan.draft_invoices_count).to eq 0
      expect(sub_plan.interval).to eq 'monthly'
      expect(sub_plan.invoice_display_name).to eq nil
      expect(sub_plan.lago_id).to be_present
      expect(sub_plan.name).to eq "Test Plan #{customer_unique_id}"
      expect(sub_plan.parent_id).to eq nil
      expect(sub_plan.pay_in_advance).to eq false
      expect(sub_plan.pending_deletion).to eq false
      expect(sub_plan.taxes).to eq []
      expect(sub_plan.trial_period).to eq nil
      expect(sub_plan.usage_thresholds).to eq []
    end
  end
end
