# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Lago::Api::Client#applied_coupons', :integration do
  def create_coupon(params = {})
    default_params = {
      name: "Coupon | #{unique_id}",
      code: "coupon-#{unique_id}",
      coupon_type: 'fixed_amount',
      amount_cents: 1000,
      amount_currency: 'EUR',
      frequency: 'once',
      expiration: 'no_expiration',
      reusable: true,
    }

    client.coupons.create(default_params.merge(params))
  end

  describe '#create' do
    let(:customer) { create_customer(presets: [:french]) }
    let(:coupon) { create_coupon }

    it 'applies a fixed amount coupon to a customer' do
      applied_coupon = client.applied_coupons.create(
        external_customer_id: customer.external_id,
        coupon_code: coupon.code,
      )

      expect(applied_coupon.lago_id).to be_present
      expect(applied_coupon.lago_coupon_id).to eq coupon.lago_id
      expect(applied_coupon.lago_customer_id).to eq customer.lago_id
      expect(applied_coupon.external_customer_id).to eq customer.external_id
      expect(applied_coupon.coupon_code).to eq coupon.code
      expect(applied_coupon.coupon_name).to eq coupon.name
      expect(applied_coupon.amount_cents).to eq 1000
      expect(applied_coupon.amount_currency).to eq 'EUR'
      expect(applied_coupon.percentage_rate).to be_nil
      expect(applied_coupon.frequency).to eq 'once'
      expect(applied_coupon.frequency_duration).to be_nil
      expect(applied_coupon.frequency_duration_remaining).to be_nil
      expect(applied_coupon.status).to eq 'active'
      expect(applied_coupon.created_at).to be_present
      expect(applied_coupon.terminated_at).to be_nil
    end

    it 'applies a percentage coupon to a customer' do
      percentage_coupon = create_coupon(
        coupon_type: 'percentage',
        percentage_rate: '15.0',
        amount_cents: nil,
        amount_currency: nil,
      )

      applied_coupon = client.applied_coupons.create(
        external_customer_id: customer.external_id,
        coupon_code: percentage_coupon.code,
      )

      expect(applied_coupon.lago_id).to be_present
      expect(applied_coupon.percentage_rate).to eq '15.0'
      expect(applied_coupon.amount_cents).to be_nil
      expect(applied_coupon.amount_currency).to be_nil
    end

    it 'applies a recurring coupon to a customer' do
      recurring_coupon = create_coupon(
        frequency: 'recurring',
        frequency_duration: 3,
      )

      applied_coupon = client.applied_coupons.create(
        external_customer_id: customer.external_id,
        coupon_code: recurring_coupon.code,
      )

      expect(applied_coupon.lago_id).to be_present
      expect(applied_coupon.frequency).to eq 'recurring'
      expect(applied_coupon.frequency_duration).to eq 3
      expect(applied_coupon.frequency_duration_remaining).to eq 3
    end

    it 'applies a forever coupon to a customer' do
      forever_coupon = create_coupon(frequency: 'forever')

      applied_coupon = client.applied_coupons.create(
        external_customer_id: customer.external_id,
        coupon_code: forever_coupon.code,
      )

      expect(applied_coupon.lago_id).to be_present
      expect(applied_coupon.frequency).to eq 'forever'
      expect(applied_coupon.frequency_duration).to be_nil
    end

    it 'allows overriding amount when applying a coupon' do
      applied_coupon = client.applied_coupons.create(
        external_customer_id: customer.external_id,
        coupon_code: coupon.code,
        amount_cents: 500,
        amount_currency: 'EUR',
      )

      expect(applied_coupon.lago_id).to be_present
      expect(applied_coupon.amount_cents).to eq 500
      expect(applied_coupon.amount_currency).to eq 'EUR'
    end

    it 'raises an error when the customer does not exist' do
      expect {
        client.applied_coupons.create(
          external_customer_id: 'non-existent-customer',
          coupon_code: coupon.code,
        )
      }.to raise_error(Lago::Api::HttpError)
    end

    it 'raises an error when the coupon does not exist' do
      expect {
        client.applied_coupons.create(
          external_customer_id: customer.external_id,
          coupon_code: 'non-existent-coupon',
        )
      }.to raise_error(Lago::Api::HttpError)
    end
  end

  describe '#get_all' do
    let(:customer) { create_customer(presets: [:french]) }
    let(:coupon) { create_coupon }

    before do
      client.applied_coupons.create(
        external_customer_id: customer.external_id,
        coupon_code: coupon.code,
      )
    end

    it 'returns all applied coupons' do
      result = client.applied_coupons.get_all

      meta = result['meta']
      expect(meta['current_page']).to eq 1
      expect(meta['total_count']).to be >= 1
      expect(meta['total_pages']).to be >= 1

      applied_coupons = result['applied_coupons']
      expect(applied_coupons.count).to be >= 1

      first_applied_coupon = applied_coupons.first
      expect(first_applied_coupon['lago_id']).to be_present
      expect(first_applied_coupon['external_customer_id']).to be_present
      expect(first_applied_coupon['status']).to eq 'active'
    end

    it 'returns applied coupons with pagination' do
      result = client.applied_coupons.get_all(per_page: 1, page: 1)

      meta = result['meta']
      expect(meta['current_page']).to eq 1

      applied_coupons = result['applied_coupons']
      expect(applied_coupons.count).to eq 1
    end

    it 'filters applied coupons by status' do
      result = client.applied_coupons.get_all(status: 'active')

      applied_coupons = result['applied_coupons']
      expect(applied_coupons).to all(satisfy { |ac| ac['status'] == 'active' })
    end

    it 'filters applied coupons by external_customer_id' do
      result = client.applied_coupons.get_all(external_customer_id: customer.external_id)

      applied_coupons = result['applied_coupons']
      expect(applied_coupons).to all(satisfy { |ac| ac['external_customer_id'] == customer.external_id })
    end
  end

  describe '#destroy' do
    let(:customer) { create_customer(presets: [:french]) }
    let(:coupon) { create_coupon }
    let(:applied_coupon) do
      client.applied_coupons.create(
        external_customer_id: customer.external_id,
        coupon_code: coupon.code,
      )
    end

    it 'destroys an applied coupon' do
      destroyed_coupon = client.applied_coupons.destroy(customer.external_id, applied_coupon.lago_id)

      expect(destroyed_coupon.lago_id).to eq applied_coupon.lago_id
      expect(destroyed_coupon.status).to eq 'terminated'
      expect(destroyed_coupon.terminated_at).to be_present
    end

    it 'raises an error when the applied coupon does not exist' do
      expect {
        client.applied_coupons.destroy(customer.external_id, 'non-existent-id')
      }.to raise_error(Lago::Api::HttpError)
    end
  end
end
