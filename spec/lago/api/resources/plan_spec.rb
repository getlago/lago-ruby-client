# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Plan do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:factory_plan) { build(:plan) }
  let(:response) do
    {
      'plan' => {
        'lago_id' => 'this-is-lago-id',
        'name' => factory_plan.name,
        'invoice_display_name' => factory_plan.invoice_display_name,
        'created_at' => '2022-04-29T08:59:51Z',
        'code' => factory_plan.code,
        'interval' => factory_plan.amount_cents,
        'description' => factory_plan.amount_currency,
        'amount_cents' => factory_plan.expiration,
        'amount_currency' => factory_plan.expiration_duration,
        'trial_period' => 2,
        'pay_in_advance' => false,
        'bill_charges_monthly' => false,
        'active_subscriptions_count' => 0,
        'draft_invoices_count' => 0,
        'charges' => [
          {
            'lago_id' => 'id1',
            'lago_billable_metric_id' => factory_plan.charges.first[:lago_billable_metric_id],
            'billable_metric_code' => 'bm_code',
            'created_at' => '2022-04-29T08:59:51Z',
            'charge_model' => factory_plan.charges.first[:charge_model],
            'pay_in_advance' => false,
            'invoiceable' => true,
            'min_amount_cents' => 0,
            'properties' => factory_plan.charges.first[:properties],
          },
        ],
        'taxes' => [{ 'code' => 'tax_code' }],
      }
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
    let(:tax_codes) { ['tax_code'] }
    let(:params) { factory_plan.to_h.merge(tax_codes: tax_codes) }
    let(:body) do
      { 'plan' => params }
    end

    context 'when plan is successfully created' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/plans')
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns an plan' do
        plan = resource.create(params)

        expect(plan.lago_id).to eq('this-is-lago-id')
        expect(plan.name).to eq(factory_plan.name)
        expect(plan.invoice_display_name).to eq(factory_plan.invoice_display_name)
        expect(plan.taxes.map(&:code)).to eq(tax_codes)
      end
    end

    context 'when plan failed to create' do
      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/plans')
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#update' do
    let(:params) { factory_plan.to_h }
    let(:body) do
      {
        'plan' => factory_plan.to_h,
      }
    end

    context 'when plan is successfully updated' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/plans/#{factory_plan.code}")
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns an plan' do
        plan = resource.update(params, factory_plan.code)

        expect(plan.lago_id).to eq('this-is-lago-id')
        expect(plan.name).to eq(factory_plan.name)
        expect(plan.invoice_display_name).to eq(factory_plan.invoice_display_name)
      end
    end

    context 'when plan failed to update' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/plans/#{factory_plan.code}")
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params, factory_plan.code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get' do
    context 'when plan is successfully fetched' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{factory_plan.code}")
          .to_return(body: response, status: 200)
      end

      it 'returns an plan' do
        plan = resource.get(factory_plan.code)

        expect(plan.lago_id).to eq('this-is-lago-id')
        expect(plan.name).to eq(factory_plan.name)
        expect(plan.invoice_display_name).to eq(factory_plan.invoice_display_name)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, "https://api.getlago.com/api/v1/plans/#{factory_plan.code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get(factory_plan.code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#destroy' do
    context 'when plan is successfully destroyed' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/plans/#{factory_plan.code}")
          .to_return(body: response, status: 200)
      end

      it 'returns an plan' do
        plan = resource.destroy(factory_plan.code)

        expect(plan.lago_id).to eq('this-is-lago-id')
        expect(plan.name).to eq(factory_plan.name)
        expect(plan.invoice_display_name).to eq(factory_plan.invoice_display_name)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:delete, "https://api.getlago.com/api/v1/plans/#{factory_plan.code}")
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy(factory_plan.code) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#get_all' do
    let(:response) do
      {
        'plans' => [
          {
            'lago_id' => 'this-is-lago-id',
            'name' => factory_plan.name,
            'invoice_display_name' => factory_plan.invoice_display_name,
            'created_at' => '2022-04-29T08:59:51Z',
            'code' => factory_plan.code,
            'interval' => factory_plan.amount_cents,
            'description' => factory_plan.amount_currency,
            'amount_cents' => factory_plan.expiration,
            'amount_currency' => factory_plan.expiration_duration,
            'trial_period' => 2,
            'pay_in_advance' => false,
            'bill_charges_monthly' => false,
            'active_subscriptions_count' => 0,
            'draft_invoices_count' => 0,
            'charges' => [
              {
                'lago_id' => 'id',
                'lago_billable_metric_id' => factory_plan.charges.first[:lago_billable_metric_id],
                'billable_metric_code' => 'bm_code',
                'created_at' => '2022-04-29T08:59:51Z',
                'charge_model' => factory_plan.charges.first[:charge_model],
                'invoice_display_name' => factory_plan.charges.first[:invoice_display_name],
                'pay_in_advance' => false,
                'min_amount_cents' => 0,
                'properties' => factory_plan.charges.first[:properties],
                'group_properties' => [],
              }
            ]
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
        stub_request(:get, 'https://api.getlago.com/api/v1/plans')
          .to_return(body: response, status: 200)
      end

      it 'returns plans on the first page' do
        response = resource.get_all

        expect(response['plans'].first['lago_id']).to eq('this-is-lago-id')
        expect(response['plans'].first['name']).to eq(factory_plan.name)
        expect(response['plans'].first['invoice_display_name']).to eq(factory_plan.invoice_display_name)
        expect(response['plans'].first['charges'].first['invoice_display_name']).to eq(factory_plan.charges.first[:invoice_display_name])
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when options are present' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/plans?per_page=2&page=1')
          .to_return(body: response, status: 200)
      end

      it 'returns plans on selected page' do
        response = resource.get_all({ per_page: 2, page: 1 })

        expect(response['plans'].first['lago_id']).to eq('this-is-lago-id')
        expect(response['plans'].first['name']).to eq(factory_plan.name)
        expect(response['plans'].first['invoice_display_name']).to eq(factory_plan.invoice_display_name)
        expect(response['meta']['current_page']).to eq(1)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(:get, 'https://api.getlago.com/api/v1/plans')
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.get_all }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
