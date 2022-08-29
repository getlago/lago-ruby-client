# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::AppliedAddOn do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:factory_applied_add_on) { FactoryBot.build(:applied_add_on) }

  describe '#create' do
    let(:params) { factory_applied_add_on.to_h }
    let(:body) do
      {
        'applied_add_on' => factory_applied_add_on.to_h
      }
    end

    context 'when applied add-on is successfully created' do
      let(:response) do
        {
          'applied_add_on' => {
            'lago_id' => 'b7ab2926-1de8-4428-9bcd-779314ac129b',
            'lago_add_on_id' => 'b7ab2926-1de8-4428-9bcd-779314ac129b',
            'external_customer_id' => factory_applied_add_on.external_customer_id,
            'lago_customer_id' => '99a6094e-199b-4101-896a-54e927ce7bd7',
            'amount_cents' => 123,
            'amount_currency' => 'EUR',
            'created_at' => '2022-04-29T08:59:51Z',
          }
        }.to_json
      end

      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/applied_add_ons')
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns an applied add-on' do
        applied_add_on = resource.create(params)

        expect(applied_add_on.external_customer_id).to eq(factory_applied_add_on.external_customer_id)
      end
    end

    context 'when applied add-on failed to create' do
      let(:response) do
        {
          'status' => 422,
          'error' => 'Unprocessable Entity',
          'message' => 'Validation error on the record'
        }.to_json
      end

      before do
        stub_request(:post, 'https://api.getlago.com/api/v1/applied_add_ons')
          .with(body: body)
          .to_return(body: response, status: 422)
      end

      it 'raises an error' do
        expect { resource.create(params) }.to raise_error Lago::Api::HttpError
      end
    end
  end
end
