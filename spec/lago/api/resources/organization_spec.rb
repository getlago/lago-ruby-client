# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Lago::Api::Resources::Organization do
  subject(:resource) { described_class.new(client) }

  let(:client) { Lago::Api::Client.new }
  let(:factory_organization) { FactoryBot.build(:organization) }
  let(:response) do
    {
      'organization' => factory_organization.to_h,
    }.to_json
  end
  let(:error_response) do
    {
      'status' => 422,
      'error' => 'Unprocessable Entity',
      'message' => 'Validation error on the record',
    }.to_json
  end

  describe '#update' do
    let(:params) { factory_organization.to_h }
    let(:body) do
      {
        'organization' => factory_organization.to_h,
      }
    end

    context 'when organization is successfully updated' do
      before do
        stub_request(:put, 'https://api.getlago.com/api/v1/organizations')
          .with(body: body)
          .to_return(body: response, status: 200)
      end

      it 'returns an organization' do
        organization = resource.update(params)

        expect(organization.webhook_url).to eq(factory_organization.webhook_url)
        expect(organization.webhook_urls).to eq(factory_organization.webhook_urls)
        expect(organization.tax_identification_number).to eq(factory_organization.tax_identification_number)
        expect(organization.billing_configuration.invoice_grace_period).to eq(factory_organization.billing_configuration[:invoice_grace_period])
      end
    end

    context 'when organization failed to update' do
      before do
        stub_request(:put, "https://api.getlago.com/api/v1/organizations")
          .with(body: body)
          .to_return(body: error_response, status: 422)
      end

      it 'raises an error' do
        expect { resource.update(params) }.to raise_error(Lago::Api::HttpError)
      end
    end
  end
end
