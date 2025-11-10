# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#plans', :integration do
  let(:suffix) { unique_id }

  describe '#create' do
    it 'creates a plan' do
      plan = client.plans.create(
        name: "Test Plan #{suffix}",
        code: "test-plan-#{suffix}",
        interval: 'monthly',
        amount_cents: 1000,
        amount_currency: 'USD',
        pay_in_advance: false,
      )

      expect(plan.active_subscriptions_count).to eq 0
      expect(plan.amount_cents).to eq 1000
      expect(plan.amount_currency).to eq 'USD'
      expect(plan.bill_charges_monthly).to eq nil
      expect(plan.bill_fixed_charges_monthly).to eq nil
      expect(plan.charges).to eq []
      expect(plan.code).to eq "test-plan-#{suffix}"
      expect(plan.created_at).to be_present
      expect(plan.customers_count).to eq 0
      expect(plan.description).to eq nil
      expect(plan.draft_invoices_count).to eq 0
      expect(plan.entitlements).to eq []
      expect(plan.fixed_charges).to eq []
      expect(plan.interval).to eq 'monthly'
      expect(plan.invoice_display_name).to eq nil
      expect(plan.lago_id).to be_present
      expect(plan.name).to eq "Test Plan #{suffix}"
      expect(plan.parent_id).to eq nil
      expect(plan.pay_in_advance).to eq false
      expect(plan.pending_deletion).to eq false
      expect(plan.taxes).to eq []
      expect(plan.trial_period).to eq nil
      expect(plan.usage_thresholds).to eq []
    end
  end

  describe '#update' do
    it 'updates a plan' do
      plan = client.plans.create(
        name: "Test Plan #{suffix}",
        code: "test-plan-#{suffix}",
        interval: 'monthly',
        amount_cents: 1000,
        amount_currency: 'USD',
        pay_in_advance: false,
      )

      plan = client.plans.update(
        {
          name: "Updated Test Plan #{suffix}",
          amount_cents: 2000,
        },
        plan.code,
      )

      expect(plan.name).to eq "Updated Test Plan #{suffix}"
      expect(plan.amount_cents).to eq 2000
    end
  end

  describe '#destroy' do
    it 'destroys a plan' do
      plan = client.plans.create(
        name: "Test Plan #{suffix}",
        code: "test-plan-#{suffix}",
        interval: 'monthly',
        amount_cents: 1000,
        amount_currency: 'USD',
        pay_in_advance: false,
      )

      plan = client.plans.destroy(plan.code)
      expect(plan.pending_deletion).to eq true

      wait_until do
        client.plans.get(plan.code)
        true
      rescue Lago::Api::Client::NotFoundError
        false
      end
    end
  end
end
