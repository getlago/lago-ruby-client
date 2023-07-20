# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Coupon do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:factory_coupon) { build(:coupon) }
  let(:response) do
    {
      'coupon' => {
        'lago_id' => 'this-is-lago-id',
        'name' => factory_coupon.name,
        'code' => factory_coupon.code,
        'description' => factory_coupon.description,
        'amount_cents' => factory_coupon.amount_cents,
        'amount_currency' => factory_coupon.amount_currency,
        'expiration' => factory_coupon.expiration,
        'expiration_at' => factory_coupon.expiration_at,
        'coupon_type' => factory_coupon.coupon_type,
        'frequency' => factory_coupon.frequency,
        'reusable' => factory_coupon.reusable,
        'plan_codes' => factory_coupon.applies_to[:plan_codes],
        'billable_metric_codes' => factory_coupon.applies_to[:billable_metric_codes],
        'created_at' => '2022-04-29T08:59:51Z',
      },
    }.to_json
  end
  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#create' do
    let(:params) { factory_coupon.to_h }
    let(:body) do
      {
        'coupon' => factory_coupon.to_h,
      }
    end

    context 'when coupon is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/coupons')
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns an coupon' do
        coupon = resource.create(params)

        expect(coupon.lago_id).to eq('this-is-lago-id')
        expect(coupon.name).to eq(factory_coupon.name)
        expect(coupon.description).to eq(factory_coupon.description)
        expect(coupon.plan_codes).to eq(factory_coupon.applies_to[:plan_codes])
        expect(coupon.billable_metric_codes).to eq(factory_coupon.applies_to[:billable_metric_codes])
      end
    end

    context 'when coupon failed to create' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/coupons')
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#update' do
    let(:params) { factory_coupon.to_h }
    let(:body) do
      {
        'coupon' => factory_coupon.to_h,
      }
    end

    context 'when coupon is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/coupons/#{factory_coupon.code}")
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns an coupon' do
        coupon = resource.update(params, factory_coupon.code)

        expect(coupon.lago_id).to eq('this-is-lago-id')
        expect(coupon.name).to eq(factory_coupon.name)
      end
    end

    context 'when coupon failed to update' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/coupons/#{factory_coupon.code}")
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, factory_coupon.code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get' do
    context 'when coupon is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/coupons/#{factory_coupon.code}")
          .to_return(body: response, status: 200)
      end

      it 'returns an coupon' do
        coupon = resource.get(factory_coupon.code)

        expect(coupon.lago_id).to eq('this-is-lago-id')
        expect(coupon.name).to eq(factory_coupon.name)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/coupons/#{factory_coupon.code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get(factory_coupon.code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#destroy' do
    context 'when coupon is successfully destroyed' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/coupons/#{factory_coupon.code}")
          .to_return(body: response, status: 200)
      end

      it 'returns an coupon' do
        coupon = resource.destroy(factory_coupon.code)

        expect(coupon.lago_id).to eq('this-is-lago-id')
        expect(coupon.name).to eq(factory_coupon.name)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/coupons/#{factory_coupon.code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy(factory_coupon.code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:response) do
      {
        'coupons' => [
          {
            'lago_id' => 'this-is-lago-id',
            'name' => factory_coupon.name,
            'code' => factory_coupon.code,
            'description' => factory_coupon.description,
            'aggregation_type' => factory_coupon.aggregation_type,
            'field_name' => factory_coupon.field_name,
            'created_at' => '2022-04-29T08:59:51Z',
          }
        ],
        'meta': {
          'current_page' => 1,
          'next_page' => 2,
          'prev_page' => nil,
          'total_pages' => 7,
          'total_count' => 63,
        }
      }.to_json
    end

    context 'when there is no options' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/coupons')
          .to_return(body: response, status: 200)
      end

      it 'returns coupons on the first page' do
        response = resource.get_all

        expect(response['coupons'].first['lago_id']).to eq('this-is-lago-id')
        expect(response['coupons'].first['name']).to eq(factory_coupon.name)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/coupons?per_page=2&page=1')
          .to_return(body: response, status: 200)
      end

      it 'returns coupons on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['coupons'].first['lago_id']).to eq('this-is-lago-id')
        expect(response['coupons'].first['name']).to eq(factory_coupon.name)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/coupons')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
