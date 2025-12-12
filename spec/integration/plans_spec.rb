# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'

RSpec.describe 'Lago::Api::Client#plans', :integration do
  let(:suffix) { unique_id }
  let(:billable_metric) { create_billable_metric(presets: [:count_agg, :filters]) }

  def create_plan(amount_cents: 1000, interval: 'monthly')
    params = build_plan_params(name: "Test Plan #{suffix}", code: "test-plan-#{suffix}", amount_cents:, interval:)
    client.plans.create(params)
  end

  def expect_plan_attributes( # rubocop:disable Metrics/ParameterLists
    plan,
    name: "Test Plan #{suffix}",
    code: "test-plan-#{suffix}",
    amount_cents: 1000,
    interval: 'monthly',
    amount_currency: 'USD',
    pay_in_advance: false,
    pending_deletion: false,
    fixed_charges: []
  )
    expect(plan.active_subscriptions_count).to eq 0
    expect(plan.amount_cents).to eq amount_cents
    expect(plan.amount_currency).to eq amount_currency
    expect(plan.bill_charges_monthly).to be_nil
    expect(plan.bill_fixed_charges_monthly).to be_nil
    expect(plan.code).to eq code
    expect(plan.created_at).to be_present
    expect(plan.customers_count).to eq 0
    expect(plan.description).to be_nil
    expect(plan.draft_invoices_count).to eq 0
    expect(plan.interval).to eq interval
    expect(plan.invoice_display_name).to be_nil
    expect(plan.lago_id).to be_present
    expect(plan.name).to eq name
    expect(plan.parent_id).to be_nil
    expect(plan.pay_in_advance).to eq pay_in_advance
    expect(plan.pending_deletion).to eq pending_deletion
    expect(plan.trial_period).to be_nil

    expect(plan.entitlements).to eq []
    if fixed_charges == :missing
      expect(plan.fixed_charges).to be_nil
    else
      expect(plan.fixed_charges).to eq fixed_charges
    end
    expect(plan.taxes).to eq []
    expect(plan.usage_thresholds).to eq []

    expect(plan.charges.length).to eq 1
    charge = plan.charges.first
    expect(charge.applied_pricing_unit).to be_nil
    expect(charge.billable_metric_code).to eq billable_metric.code
    expect(charge.charge_model).to eq 'standard'
    expect(charge.created_at).to be_present
    expect(charge.invoice_display_name).to be_nil
    expect(charge.invoiceable).to be true
    expect(charge.lago_billable_metric_id).to eq billable_metric.lago_id
    expect(charge.lago_id).to be_present
    expect(charge.min_amount_cents).to eq 0
    expect(charge.pay_in_advance).to be true
    expect(charge.properties.amount).to eq '100.00'
    expect(charge.properties.grouped_by).to eq %w[group_key_1 group_key_2]
    expect(charge.prorated).to be false
    expect(charge.regroup_paid_fees).to be_nil
    expect(charge.taxes).to eq []

    expect(charge.filters.length).to eq 1
    filter = charge.filters.first
    expect(filter.invoice_display_name).to be_nil
    expect(filter.properties.amount).to eq('200.00')
    expect(filter.values.region).to eq(%w[us])
  end

  def build_plan_params(name:, code:, amount_cents: 1000, interval: 'monthly')
    {
      name:,
      code:,
      amount_cents:,
      interval:,
      amount_currency: 'USD',
      pay_in_advance: false,
      charges: [
        {
          billable_metric_id: billable_metric.lago_id,
          charge_model: 'standard',
          pay_in_advance: true,
          properties: {
            amount: '100.00',
            pricing_group_keys: %w[group_key_1 group_key_2],
          },
          filters: [
            {
              values: { region: %w[us] },
              properties: { amount: '200.00' },
            },
          ],
        },
      ],
    }
  end

  describe '#create' do
    it 'creates a plan' do
      plan = create_plan

      expect_plan_attributes(plan)
    end

    it 'creates a plan with all optional attributes' do
      prorated_billable_metric = create_billable_metric(presets: [:unique_count_agg], params: { recurring: true })
      tax = create_tax

      params = {
        name: "Full Plan #{suffix}",
        code: "full-plan-#{suffix}",
        amount_cents: 1000,
        amount_currency: 'USD',
        interval: 'yearly',
        description: 'A test plan with all attributes',
        trial_period: 14,
        invoice_display_name: 'Custom Display Name',
        pay_in_advance: true,
        bill_charges_monthly: true,
        tax_codes: [tax.code],
        charges: [
          {
            billable_metric_id: billable_metric.lago_id,
            charge_model: 'standard',
            pay_in_advance: true,
            invoice_display_name: 'Custom Charge Name',
            tax_codes: [tax.code],
            properties: { amount: '100.00', pricing_group_keys: %w[group_key_1 group_key_2] },
            filters: [
              { values: { region: %w[us] }, properties: { amount: '100.00' }, invoice_display_name: 'Filter US' },
              { values: { region: %w[fr] }, properties: { amount: '150.00' } },
            ],
          },
          {
            billable_metric_id: prorated_billable_metric.lago_id,
            charge_model: 'graduated',
            pay_in_advance: false,
            prorated: true,
            properties: {
              graduated_ranges: [
                { from_value: 0, to_value: 10, per_unit_amount: '1.00', flat_amount: '0' },
                { from_value: 11, to_value: nil, per_unit_amount: '0.50', flat_amount: '0' },
              ],
            },
          },
        ],
      }

      plan = client.plans.create(params)

      # Plan-level assertions
      expect(plan.description).to eq 'A test plan with all attributes'
      expect(plan.trial_period).to eq 14.0
      expect(plan.invoice_display_name).to eq 'Custom Display Name'
      expect(plan.pay_in_advance).to be true
      expect(plan.bill_charges_monthly).to be true
      expect(plan.taxes.length).to eq 1
      expect(plan.taxes.first.code).to eq tax.code

      # Charges assertions
      expect(plan.charges.length).to eq 2

      # First charge with filters
      first_charge = plan.charges.find { |c| c.billable_metric_code == billable_metric.code }
      expect(first_charge.invoice_display_name).to eq 'Custom Charge Name'
      expect(first_charge.pay_in_advance).to be true
      expect(first_charge.taxes.length).to eq 1
      expect(first_charge.taxes.first.code).to eq tax.code
      expect(first_charge.filters.length).to eq 2
      filter = first_charge.filters.find { |f| f.invoice_display_name == 'Filter US' }
      expect(filter.values.region).to eq %w[us]
      expect(filter.properties.amount).to eq '100.00'

      # Prorated charge (graduated)
      prorated_charge = plan.charges.find { |c| c.billable_metric_code == prorated_billable_metric.code }
      expect(prorated_charge.charge_model).to eq 'graduated'
      expect(prorated_charge.prorated).to be true
    end
  end

  describe '#update' do
    let(:plan) { create_plan }

    it 'updates a plan' do
      charge = plan.charges.first
      params = {
        name: "Updated Plan #{suffix}",
        amount_cents: 2000,
        description: 'Updated description',
        trial_period: 30,
        invoice_display_name: 'Updated Display Name',
        charges: [
          {
            id: charge.lago_id,
            billable_metric_id: charge.lago_billable_metric_id,
            charge_model: 'standard',
            invoice_display_name: 'Updated Charge Name',
            properties: { amount: '200.00', grouped_by: %w[new_key] },
            filters: [
              { values: { region: %w[fr] }, properties: { amount: '300.00' } },
            ],
          },
        ],
      }
      updated_plan = client.plans.update(params, plan.code)

      expect(updated_plan.name).to eq "Updated Plan #{suffix}"
      expect(updated_plan.amount_cents).to eq 2000
      expect(updated_plan.description).to eq 'Updated description'
      expect(updated_plan.trial_period).to eq 30.0
      expect(updated_plan.invoice_display_name).to eq 'Updated Display Name'

      updated_charge = updated_plan.charges.first
      expect(updated_charge.invoice_display_name).to eq 'Updated Charge Name'
      expect(updated_charge.properties.amount).to eq '200.00'
      expect(updated_charge.properties.grouped_by).to eq %w[new_key]

      updated_filter = updated_charge.filters.first
      expect(updated_filter.values.region).to eq %w[fr]
      expect(updated_filter.properties.amount).to eq '300.00'
    end
  end

  describe '#get' do
    let(:plan) { create_plan }

    it 'retrieves a plan' do
      fetched_plan = client.plans.get(plan.code)

      expect_plan_attributes(fetched_plan, name: plan.name, code: plan.code)

      expect(fetched_plan.lago_id).to eq plan.lago_id
    end
  end

  describe '#get_all' do
    before_all_integration_tests do
      @billable_metric = create_billable_metric(presets: [:count_agg, :filters])
      @plans = Array.new(3) do
        suffix = unique_id
        params = build_plan_params(name: "Integration Plan #{suffix}", code: "integration-plan-#{suffix}")
        client.plans.create(params)
      end.reverse
    end

    attr_reader :plans,
                :billable_metric

    def fetch_plans(params = {})
      params = { page: 1, per_page: plans.count }.merge(params)

      client.plans.get_all(params)
    end

    it 'returns the created plans' do
      response = fetch_plans

      meta = response.meta
      expect(meta.current_page).to eq 1
      expect(meta.total_pages).to be >= 1
      expect(meta.total_count).to be >= plans.count
      expect(meta.prev_page).to be_nil
      expect(meta.next_page).to be_nil.or(be >= 2)

      fetched_plans = response.plans
      expect(fetched_plans.count).to be >= 3
      expect(fetched_plans[..2].map(&:lago_id)).to eq plans.map(&:lago_id)

      fetched_plans[..2].each_with_index do |fetched_plan, index|
        expect_plan_attributes(
          fetched_plan,
          name: plans[index].name,
          code: plans[index].code,
          fixed_charges: :missing,
        )
      end
    end

    context 'when paginating' do
      it 'returns the plans for the requested page' do
        plans.each_with_index do |plan, index|
          response = fetch_plans(page: index + 1, per_page: 1)

          meta = response.meta
          expect(meta.current_page).to eq(index + 1)
          expect(meta.total_pages).to be >= 3
          expect(meta.total_count).to be >= 3

          expect(response.plans.count).to eq 1
          fetched_plan = response.plans.first
          expect(fetched_plan.lago_id).to eq plan.lago_id
        end
      end
    end
  end

  describe '#destroy' do
    let(:plan) { create_plan }

    it 'destroys a plan' do
      destroyed_plan = client.plans.destroy(plan.code)
      expect_plan_attributes(destroyed_plan, pending_deletion: true)

      wait_until do
        client.plans.get(plan.code)
        false
      rescue Lago::Api::HttpError => e
        expect(e.error_code).to eq 404
        expect(e.error_body).to eq({ 'status' => 404, 'error' => 'Not Found', 'code' => 'plan_not_found' }.to_json)
        true
      end
    end
  end
end
