# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#events', :integration do
  def setup_subscription(billable_metric_preset: [:count_agg])
    billable_metric = create_billable_metric(presets: billable_metric_preset)
    plan = create_plan(
      params: {
        charges: [
          {
            billable_metric_id: billable_metric.lago_id,
            charge_model: 'standard',
            pay_in_advance: false,
            properties: { amount: '100.00' },
          },
        ],
      },
    )
    customer = create_customer(presets: [:french])
    subscription = create_subscription(external_customer_id: customer.external_id, plan_code: plan.code)
    [billable_metric.code, subscription.external_id]
  end

  describe '#create' do
    let(:billable_metric_code_and_external_subscription_id) { setup_subscription }
    let(:billable_metric_code) { billable_metric_code_and_external_subscription_id[0] }
    let(:external_subscription_id) { billable_metric_code_and_external_subscription_id[1] }

    it 'creates an event' do
      transaction_id = SecureRandom.uuid
      timestamp = Time.now.to_i
      response = client.events.create(
        {
          transaction_id:,
          code: billable_metric_code,
          external_subscription_id:,
          timestamp:,
          properties: { region: 'us' },
        },
      )

      expect(response.lago_id).to be_present
      expect(response.transaction_id).to eq(transaction_id)
      expect(response.timestamp).to eq(Time.at(timestamp).utc.iso8601(3))
      expect(response.code).to eq(billable_metric_code)
      expect(response.lago_customer_id).to be_nil
      expect(response.lago_subscription_id).to be_nil
      expect(response.external_subscription_id).to eq(external_subscription_id)
      expect(response.created_at).to be_present
      expect(response.properties.region).to eq('us')
    end
  end

  describe '#batch_create' do
    let(:billable_metric_code_and_external_subscription_id) do
      setup_subscription(billable_metric_preset: [:unique_count_agg])
    end
    let(:billable_metric_code) { billable_metric_code_and_external_subscription_id[0] }
    let(:external_subscription_id) { billable_metric_code_and_external_subscription_id[1] }

    it 'creates multiple events' do
      transaction_id1 = SecureRandom.uuid
      timestamp1 = Time.now.to_f - 10
      transaction_id2 = SecureRandom.uuid
      timestamp2 = Time.now.to_f
      response = client.events.batch_create(
        events: [
          {
            transaction_id: transaction_id1,
            code: billable_metric_code,
            external_subscription_id:,
            timestamp: timestamp1,
            properties: { region: 'us', value: 100 },
          },
          {
            transaction_id: transaction_id2,
            code: billable_metric_code,
            external_subscription_id:,
            timestamp: timestamp2,
            properties: { region: 'eu', value: 200 },
          },
        ],
      )

      events = response.events

      expect(events.length).to eq(2)

      first_event = events.first
      expect(first_event.lago_id).to be_present
      expect(first_event.transaction_id).to eq transaction_id1
      expect(first_event.lago_customer_id).to be_nil
      expect(first_event.code).to eq billable_metric_code
      expect(first_event.timestamp).to eq Time.at(timestamp1).utc.iso8601(3)
      expect(first_event.precise_total_amount_cents).to be_nil
      expect(first_event.properties.region).to eq('us')
      expect(first_event.properties.value).to eq(100)
      expect(first_event.lago_subscription_id).to be_nil
      expect(first_event.external_subscription_id).to eq external_subscription_id
      expect(first_event.created_at).to be_present

      last_event = events.last
      expect(last_event.lago_id).to be_present
      expect(last_event.transaction_id).to eq transaction_id2
      expect(last_event.lago_customer_id).to be_nil
      expect(last_event.code).to eq billable_metric_code
      expect(last_event.timestamp).to eq Time.at(timestamp2).utc.iso8601(3)
      expect(last_event.precise_total_amount_cents).to be_nil
      expect(last_event.properties.region).to eq('eu')
      expect(last_event.properties.value).to eq(200)
      expect(last_event.lago_subscription_id).to be_nil
      expect(last_event.external_subscription_id).to eq external_subscription_id
      expect(last_event.created_at).to be_present
    end
  end

  describe '#get_all' do
    before_all_integration_tests do
      @billable_metric_code1,  @external_subscription_id1 = setup_subscription(billable_metric_preset: [:sum_agg])
      @billable_metric_code2,  @external_subscription_id2 = setup_subscription

      @transaction_id1 = SecureRandom.uuid
      @timestamp1 = Time.now.to_f
      client.events.create(
        {
          transaction_id: transaction_id1,
          code: billable_metric_code1,
          external_subscription_id: external_subscription_id1,
          timestamp: timestamp1,
          properties: { region: 'us', value: 100 },
        },
      )

      @transaction_id2 = SecureRandom.uuid
      @timestamp2 = Time.now.to_f
      client.events.create(
        {
          transaction_id: transaction_id2,
          code: billable_metric_code2,
          external_subscription_id: external_subscription_id2,
          timestamp: timestamp2,
          properties: { region: 'eu' },
        },
      )
    end

    attr_reader :billable_metric_code1,
                :external_subscription_id1,
                :billable_metric_code2,
                :external_subscription_id2,
                :transaction_id1,
                :timestamp1,
                :transaction_id2,
                :timestamp2

    def test_filtered_events(expected_transaction_id:, params: {})
      params[:page] = 1
      params[:per_page] = 1
      response = client.events.get_all(params)
      meta = response.meta
      events = response.events

      expect(meta.current_page).to eq(1)
      expect(meta.total_pages).to be >= 1
      expect(meta.total_count).to be >= 1
      expect(meta.next_page).to eq(2).or(be_nil)
      expect(meta.prev_page).to be_nil

      expect(events.length).to eq(1)
      expect(events[0].transaction_id).to eq(expected_transaction_id)
    end

    it 'gets all events' do
      response = client.events.get_all

      meta = response.meta
      events = response.events

      expect(meta.current_page).to eq(1)
      expect(meta.total_pages).to be >= 1
      expect(meta.total_count).to be >= 2
      expect(meta.next_page).to be_nil.or(be >= 2)
      expect(meta.prev_page).to be_nil

      expect(events.length).to be >= 2
      first_event = events.first
      expect(first_event.lago_id).to be_present
      expect(first_event.transaction_id).to eq(transaction_id2)
      expect(first_event.timestamp).to eq(Time.at(timestamp2).utc.iso8601(3))
      expect(first_event.code).to eq(billable_metric_code2)
      expect(first_event.lago_customer_id).to be_nil
      expect(first_event.lago_subscription_id).to be_nil
      expect(first_event.external_subscription_id).to eq(external_subscription_id2)
      expect(first_event.created_at).to be_present
      expect(first_event.properties.region).to eq('eu')

      second_event = events[1]
      expect(second_event.lago_id).to be_present
      expect(second_event.transaction_id).to eq(transaction_id1)
      expect(second_event.timestamp).to eq(Time.at(timestamp1).utc.iso8601(3))
      expect(second_event.code).to eq(billable_metric_code1)
      expect(second_event.lago_customer_id).to be_nil
      expect(second_event.lago_subscription_id).to be_nil
      expect(second_event.external_subscription_id).to eq(external_subscription_id1)
      expect(second_event.created_at).to be_present
      expect(second_event.properties.region).to eq('us')
    end

    context 'when paginating' do
      it 'gets all events' do
        response = client.events.get_all(page: 1, per_page: 1)
        meta = response.meta
        events = response.events

        expect(meta.current_page).to eq(1)
        expect(meta.total_pages).to be >= 2
        expect(meta.total_count).to be >= 2
        expect(meta.next_page).to eq(2)
        expect(meta.prev_page).to be_nil

        expect(events.length).to eq(1)
        expect(events[0].transaction_id).to eq(transaction_id2)

        response = client.events.get_all(page: 2, per_page: 1)
        meta = response.meta
        events = response.events

        expect(meta.current_page).to eq(2)
        expect(meta.total_pages).to be >= 2
        expect(meta.total_count).to be >= 2
        expect(meta.next_page).to eq(3).or(be_nil)
        expect(meta.prev_page).to eq(1)

        expect(events.length).to eq(1)
        expect(events[0].transaction_id).to eq(transaction_id1)
      end
    end

    context 'when filtering by code' do
      it 'gets filtered events' do
        test_filtered_events(expected_transaction_id: transaction_id1, params: { code: billable_metric_code1 })
      end
    end

    context 'when filtering by external_subscription_id' do
      it 'gets filtered events' do
        test_filtered_events(
          expected_transaction_id: transaction_id1,
          params: { external_subscription_id: external_subscription_id1 },
        )
      end
    end

    context 'when filtering by timestamp_from' do
      it 'gets filtered events' do
        test_filtered_events(
          expected_transaction_id: transaction_id2,
          params: { timestamp_from: Time.at(timestamp2).utc.iso8601(3) },
        )
      end
    end

    context 'when filtering by timestamp_to' do
      it 'gets filtered events' do
        test_filtered_events(
          expected_transaction_id: transaction_id1,
          params: { timestamp_to: Time.at(timestamp2).utc.iso8601(3) },
        )
      end
    end
  end
end
