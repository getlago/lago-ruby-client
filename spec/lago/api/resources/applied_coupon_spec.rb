# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::AppliedCoupon do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:factory_applied_coupon) { FactoryBot.build(:applied_coupon) }

  describe '#create' do
    let(:params) { factory_applied_coupon.to_h }
    let(:body) do
      {
        'applied_coupon' => factory_applied_coupon.to_h
      }
    end

    context 'when applied coupon is successfully created' do
      let(:response) do
        {
          'applied_coupon' => {
            'lago_id' => 'b7ab2926-1de8-4428-9bcd-779314ac129b',
            'lago_coupon_id' => 'b7ab2926-1de8-4428-9bcd-779314ac129b',

            'customer_id' => factory_applied_coupon.customer_id,
            'lago_customer_id' => '99a6094e-199b-4101-896a-54e927ce7bd7',
            'amount_cents' => 123,
            'amount_currency' => 'EUR',
            'expiration_date' => '2022-04-29',
            'created_at' => '2022-04-29T08:59:51Z',
            'terminated_at' => '2022-04-29T08:59:51Z'
          }
        }.to_json
      end

      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/applied_coupons')
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns an applied_coupon' do
        applied_coupon = resource.create(params)

        expect(applied_coupon.customer_id).to eq(factory_applied_coupon.customer_id)
      end
    end

    context 'when applied coupon failed to create' do
      let(:response) do
        {
          'status' => 422,
          'error' => 'Unprocessable Entity',
          'message' => 'Validation error on the record'
        }.to_json
      end

      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/applied_coupons')
          .with(body: body)
          .to_return(body: response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
