# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::AppliedCoupon do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:factory_applied_coupon) { build(:applied_coupon) }
  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#create' do
    let(:params) { factory_applied_coupon.to_h }
    let(:body) do
      {
        'applied_coupon' => factory_applied_coupon.to_h,
      }
    end

    context 'when applied coupon is successfully created' do
      let(:response) do
        {
          'applied_coupon' => {
            'lago_id' => 'b7ab2926-1de8-4428-9bcd-779314ac129b',
            'lago_coupon_id' => 'b7ab2926-1de8-4428-9bcd-779314ac129b',
            'external_customer_id' => factory_applied_coupon.external_customer_id,
            'lago_customer_id' => '99a6094e-199b-4101-896a-54e927ce7bd7',
            'frequency' => factory_applied_coupon.frequency,
            'amount_cents' => 123,
            'amount_currency' => 'EUR',
            'expiration_at' => '2022-04-29T08:59:51Z',
            'created_at' => '2022-04-29T08:59:51Z',
            'terminated_at' => '2022-04-29T08:59:51Z',
          },
        }.to_json
      end

      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/applied_coupons')
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns an applied_coupon' do
        applied_coupon = resource.create(params)

        expect(applied_coupon.external_customer_id).to eq(factory_applied_coupon.external_customer_id)
      end
    end

    context 'when applied coupon failed to create' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/applied_coupons')
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:response) do
      {
        'applied_coupons' => [
          {
            'lago_id' => 'this-is-lago-id',
            'lago_coupon_id' => 'b7ab2926-1de8-4428-9bcd-779314ac129b',
            'external_customer_id' => factory_applied_coupon.external_customer_id,
            'lago_customer_id' => '99a6094e-199b-4101-896a-54e927ce7bd7',
            'frequency' => factory_applied_coupon.frequency,
            'status' => 'active',
            'amount_cents' => 123,
            'amount_cents_remaining' => 50,
            'amount_currency' => 'EUR',
            'frequency_duration' => 3,
            'frequency_duration_remaining' => 1,
            'expiration_at' => '2022-04-29T08:59:51Z',
            'created_at' => '2022-04-29T08:59:51Z',
            'terminated_at' => '2022-04-29T08:59:51Z',
          },
        ],
        'meta': {
          'current_page' => 1,
          'next_page' => 2,
          'prev_page' => nil,
          'total_pages' => 7,
          'total_count' => 63,
        },
      }.to_json
    end

    context 'when there is no options' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/applied_coupons')
          .to_return(body: response, status: 200)
      end

      it 'returns applied coupons on the first page' do
        response = resource.get_all

        expect(response['applied_coupons'].first['lago_id']).to eq('this-is-lago-id')
        expect(response['applied_coupons'].first['lago_coupon_id']).to eq('b7ab2926-1de8-4428-9bcd-779314ac129b')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/applied_coupons?per_page=2&page=1')
          .to_return(body: response, status: 200)
      end

      it 'returns applied coupons on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['applied_coupons'].first['lago_id']).to eq('this-is-lago-id')
        expect(response['applied_coupons'].first['lago_coupon_id']).to eq('b7ab2926-1de8-4428-9bcd-779314ac129b')
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/applied_coupons')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#destroy' do
    let(:lago_id) { 'b7ab2926-1de8-4428-9bcd-779314ac129b' }
    let(:response) do
      {
        'applied_coupon' => {
          'lago_id' => lago_id,
          'lago_coupon_id' => 'b7ab2926-1de8-4428-9bcd-779314ac129b',
          'external_customer_id' => external_customer_id,
          'lago_customer_id' => '99a6094e-199b-4101-896a-54e927ce7bd7',
          'frequency' => factory_applied_coupon.frequency,
          'amount_cents' => 123,
          'amount_currency' => 'EUR',
          'expiration_at' => '2022-04-29T08:59:51Z',
          'created_at' => '2022-04-29T08:59:51Z',
          'terminated_at' => '2022-04-29T08:59:51Z',
        },
      }.to_json
    end
    let(:external_customer_id) { factory_applied_coupon.external_customer_id }

    context 'when applied coupon is successfully destroyed' do
      before do
        stub_request(
          :delete,
          "https://api.getlago.com/api/v1/customers/#{factory_applied_coupon.external_customer_id}/applied_coupons/#{lago_id}",
        ).to_return(body: response, status: 200)
      end

      it 'returns an applied coupon' do
        applied_coupon = resource.destroy(factory_applied_coupon.external_customer_id, lago_id)

        expect(applied_coupon.external_customer_id).to eq(factory_applied_coupon.external_customer_id)
      end
    end

    context 'when customer id contains special characters' do
      let(:external_customer_id) { 'customer+id/with special@chars' }

      before do
        stub_request(
          :delete,
          "https://api.getlago.com/api/v1/customers/customer+id%2Fwith%20special@chars/applied_coupons/#{lago_id}",
        ).to_return(body: response, status: 200)
      end

      it 'escapes the customer id in the request URL' do
        resource.destroy(external_customer_id, lago_id)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(
          :delete,
          "https://api.getlago.com/api/v1/customers/#{factory_applied_coupon.external_customer_id}/applied_coupons/#{lago_id}",
        ).to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect {
          resource.destroy(factory_applied_coupon.external_customer_id, lago_id)
        }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
