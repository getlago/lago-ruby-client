# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Coupon do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:coupon_response) { load_fixture('coupon') }
  let(:coupon_code) { JSON.parse(coupon_response)['coupon']['code'] }
  let(:coupon_id) { JSON.parse(coupon_response)['coupon']['lago_id'] }

  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#create' do
    let(:params) { create(:coupon).to_h }

    context 'when coupon is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/coupons')
          .with(body: { coupon: params })
          .to_return(body: coupon_response, status: 200)
      end

      it 'returns an coupon' do
        coupon = resource.create(params)

        expect(coupon.lago_id).to eq(coupon_id)
        expect(coupon.name).to eq('coupon_name')
        expect(coupon.description).to eq('coupon_description')
        expect(coupon.plan_codes).to eq(['plan1'])
        expect(coupon.billable_metric_codes).to eq([])
      end
    end

    context 'when coupon failed to create' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/coupons')
          .with(body: { coupon: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#update' do
    let(:params) { create(:coupon).to_h }

    context 'when coupon is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/coupons/#{coupon_code}")
          .with(body: { coupon: params })
          .to_return(body: coupon_response, status: 200)
      end

      it 'returns an coupon' do
        coupon = resource.update(params, coupon_code)

        expect(coupon.lago_id).to eq(coupon_id)
        expect(coupon.name).to eq('coupon_name')
      end
    end

    context 'when coupon failed to update' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/coupons/#{coupon_code}")
          .with(body: { coupon: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, coupon_code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get' do
    context 'when coupon is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/coupons/#{coupon_code}")
          .to_return(body: coupon_response, status: 200)
      end

      it 'returns an coupon' do
        coupon = resource.get(coupon_code)

        expect(coupon.lago_id).to eq(coupon_id)
        expect(coupon.name).to eq('coupon_name')
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/coupons/#{coupon_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get(coupon_code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#destroy' do
    context 'when coupon is successfully destroyed' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/coupons/#{coupon_code}")
          .to_return(body: coupon_response, status: 200)
      end

      it 'returns an coupon' do
        coupon = resource.destroy(coupon_code)

        expect(coupon.lago_id).to eq(coupon_id)
        expect(coupon.name).to eq('coupon_name')
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/coupons/#{coupon_code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy(coupon_code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:response) do
      {
        'coupons' => [JSON.parse(coupon_response)['coupon']],
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

        expect(response['coupons'].first['lago_id']).to eq(coupon_id)
        expect(response['coupons'].first['name']).to eq('coupon_name')
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

        expect(response['coupons'].first['lago_id']).to eq(coupon_id)
        expect(response['coupons'].first['name']).to eq('coupon_name')
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
