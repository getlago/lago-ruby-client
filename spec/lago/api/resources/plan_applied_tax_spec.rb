# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::PlanAppliedTax do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }

  let(:applied_tax_response) { load_fixture('plan_applied_tax') }
  let(:plan_code) { JSON.parse(applied_tax_response)['applied_tax']['plan_code'] }
  let(:tax_code) { JSON.parse(applied_tax_response)['applied_tax']['tax_code'] }

  let(:error_response) { load_fixture('validation_error') }

  describe '#create' do
    let(:params) { create(:create_plan_applied_tax).to_h }

    context 'when applied tax is successfully created' do
      before do
        stub_request(:post, "https://api.getlago.com/api/v1/plans/#{plan_code}/applied_taxes")
          .with(body: { applied_tax: params })
          .to_return(body: applied_tax_response, status: 200)
      end

      it 'returns an applied tax' do
        applied_tax = resource.create(plan_code, params)

        expect(applied_tax.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
        expect(applied_tax.plan_code).to eq('plan_code')
        expect(applied_tax.tax_code).to eq('tax_code')
      end
    end

    context 'when applied tax failed to create' do
      before do
        stub_request(:post, "https://api.getlago.com/api/v1/plans/#{plan_code}/applied_taxes")
          .with(body: { applied_tax: params })
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(plan_code, params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end

  describe '#destroy' do
    context 'when applied tax is successfully destroyed' do
      before do
        stub_request(
          :delete,
          "https://api.getlago.com/api/v1/plans/#{plan_code}/applied_taxes/#{tax_code}",
        ).to_return(body: applied_tax_response, status: 200)
      end

      it 'returns an applied tax' do
        applied_tax = resource.destroy(plan_code, tax_code)

        expect(applied_tax.lago_id).to eq('1a901a90-1a90-1a90-1a90-1a901a901a90')
      end
    end

    context 'when applied tax failed to destroy' do
      before do
        stub_request(
          :delete,
          "https://api.getlago.com/api/v1/plans/#{plan_code}/applied_taxes/#{tax_code}",
        ).to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.destroy(plan_code, tax_code) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end
end
