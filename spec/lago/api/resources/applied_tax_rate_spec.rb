# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::AppliedTaxRate do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:applied_tax_rate) { FactoryBot.build(:applied_tax_rate) }
  let(:response) do
    {
      'applied_tax_rate' => {
        'lago_id' => 'this-is-lago-id',
        'lago_customer_id' => 'this-is-lago-customer-id',
        'lago_tax_rate_id' => 'this-is-lago-tax-rate-id',
        'tax_rate_code' => applied_tax_rate.tax_rate_code,
        'external_customer_id' => applied_tax_rate.external_customer_id,
        'created_at' => '2022-04-29T08:59:51Z',
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
    let(:params) do
      { tax_rate_code: applied_tax_rate.tax_rate_code }
    end

    let(:body) do
      { 'applied_tax_rate' => params.to_h }
    end

    context 'when tax rate is successfully created' do
      before do
        stub_request(
          :post,
          "https://api.getlago.com/api/v1/customers/#{applied_tax_rate.external_customer_id}/applied_tax_rates",
        ).with(body: body)
         .to_return(body: response, status: 200)
      end

      it 'returns an applied tax rate' do
        applied_tax = resource.create(applied_tax_rate.external_customer_id, params)

        expect(applied_tax.lago_id).to eq('this-is-lago-id')
        expect(applied_tax.tax_rate_code).to eq(applied_tax_rate.tax_rate_code)
      end
    end

    context 'when applied_tax_rate failed to create' do
      before do
        stub_request(
          :post,
          "https://api.getlago.com/api/v1/customers/#{applied_tax_rate.external_customer_id}/applied_tax_rates",
        ).with(body: body)
         .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(applied_tax_rate.external_customer_id, params) }.to raise_error Lago::Api::HttpError
      end
    end
  end

  describe '#destroy' do
    context 'when applied tax rate is successfully destroyed' do
      before do
        stub_request(
          :delete,
          "https://api.getlago.com/api/v1/customers/#{applied_tax_rate.external_customer_id}/applied_tax_rates/#{applied_tax_rate.tax_rate_code}",
        ).to_return(body: response, status: 200)
      end

      it 'returns an applied tax rate' do
        applied_tax = resource.destroy(
          applied_tax_rate.external_customer_id,
          applied_tax_rate.tax_rate_code,
        )

        expect(applied_tax.lago_id).to eq('this-is-lago-id')
        expect(applied_tax.tax_rate_code).to eq(applied_tax_rate.tax_rate_code)
      end
    end

    context 'when there is an issue' do
      before do
        stub_request(
          :delete,
          "https://api.getlago.com/api/v1/customers/#{applied_tax_rate.external_customer_id}/applied_tax_rates/#{applied_tax_rate.tax_rate_code}",
        ).to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect do
          resource.destroy(applied_tax_rate.external_customer_id, applied_tax_rate.tax_rate_code)
        end.to raise_error(Lago::Api::HttpError)
      end
    end
  end
end
